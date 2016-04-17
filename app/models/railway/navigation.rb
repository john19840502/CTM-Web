class Navigation < DatabaseRailway
  include Rails.application.routes.url_helpers
  acts_as_tree order: 'sort_index'
  acts_as_list :scope => :parent

  acts_as_taggable
  acts_as_taggable_on :roles
  attr_accessible :role_list, :key, :name, :path, :label, :sort_index
  
  # belongs_to :subdomain
  
  # has_many :navigational_contexts
  # has_many :roles, :through => :navigational_contexts

  validates :name,   presence: true
  # validates :name,   uniqueness: true
  validates :label,  presence: true
  # validates :label,  uniqueness: true

  validates :key,    presence: true
  validates :path,   presence: true

#  default_scope { order('sort_index') }
  
  
  #####
  # Tell ActiveRecord how to serialize our data.
  #####
  serialize :options, Hash
  
  before_validation :set_values

  def self.make_main_menu(name, label, hash = nil)
    n = Navigation.find_or_create_by!(:name => name, :label => label, :path => 'root_path')
    n.save
    n.add_menu hash if hash
  end

  def url
    Rails.application.routes.url_helpers.send(self.path) rescue '/'
  end

  # Label display for dropdown select
  def menu_name
    label.nil? ? label : name
  end
  
  def set_values
    self.key = "#{self.parent.name rescue 'root'}_#{self.name}_#{self.path}".downcase.gsub(' ','_')
    # self.subdomain = self.parent.subdomain rescue nil
  end
  
  # Return the navigation array for the provided context
  def self.nav_for_current_context(context=nil)
    root = self.where(uuid: context).first
    if root.blank?
      return self.not_found      
    else
      items = root.children.map{|node| Navigation.render_item(node)}
      items.empty? ? self.not_found('No Navigation Found') : items
    end
  end
  
  # A method to determine navigation items for an array or list of roles
  def self.for_roles(roles)
    # GJF changed true to 'distinct' here since if it's not distinct tihs query tries 
    # to do some kind of weird group statement that SQL Server chokes on.
    self.tagged_with(roles, :any => 'distinct')
  rescue
    Navigation.new(name: 'ERROR IN FINDING MENUS', label: 'ERROR')
  end

  # All menu contexts for a set of user roles
  def self.valid_contexts(roles)
    self.tagged_with(roles, :any => 'distinct').map{|n| n.uuid}
  end

  # Is the current context valid for the users roles?
  def self.valid_context?(context, roles)
    self.valid_contexts(roles).include?(context) rescue false
  end

  def self.invalid_context?(context, roles)
    !self.valid_context?(context, roles)
  end

  # First context of first valid navigation
  def self.default_context(roles)
    self.for_roles(roles).first.uuid rescue 'error'
  end

  def self.uuid_for_context(context=nil)
    self.find_by_name(context).uuid
  rescue
    'UUID MISSING FOR CONTEXT'
  end

  # A recursive algorithm to render a menu item and its children
  def self.render_item(item)
    {key:      item.key.to_sym, 
     name:     item.name, 
     url:      item.url, 
     options:  item.options, 
     items:    item.children.map{|item| Navigation.render_item(item)}} rescue {:key => :main, :name => 'Error Rendering Navigation Item', :url => '/main', :options => {}, :items => []}
  end
  
  def self.not_found(msg = 'No menu available')
    [Navigation.render_item(Navigation.new(key:'main', name:msg, path:'root_path'))]
  end

  def add_menu hsh
    hsh.each_with_index { |pair, i|
      k = pair[0]
      v = pair[1]
      if (v.is_a? Hash)
        sub_menu = children.find_or_create_by!(:name => k, :label => k, :path => '#', :sort_index => i)
        sub_menu.add_menu v
        sub_menu.sort_index = i
        sub_menu.save!
      else
        nav = children.find_or_create_by!(:name => k, :label => k, :path => v, :sort_index => i)
        nav.sort_index = i
        nav.save!
      end
    }
  end

  def self.routes
    good_paths = ['_path']
    bad_paths = ['rails_','hash_','edit_','view_','update_','show_','validations_','exceptions_','row_','reorder_','render_','new_','mark_','filter_','destroy_','add_existing_','add_association_']
    bad_routes  = Rails.application.routes.named_routes.helpers.map{|r| r if !!(r =~ /#{bad_paths.join('|')}/)}.compact.sort
    good_routes = Rails.application.routes.named_routes.helpers.map{|r| r if !!(r =~ /#{good_paths.join('|')}/)}.compact.sort
    good_routes - bad_routes
  end
end
