# == Awesome Nested Set View Helper
#
# Ilya Zykin, zykin-ilya@ya.ru, Russia, Ivanovo 2009-2011
#
# github.com/the-teacher   (Publicated by MIT)
module AnsHelper  
  def ans_controls(node, options= {})
    opts= {
      :class_name=>nil,   # class of nested elements
      :id_field=>'id',    # id field name, id by default
      :first=>false,      # first element flag
      :last=>false,       # last element flag
      :has_childs=>false  # has childs?
    }.merge!(options)

    render :partial => "#{opts[:path]}/controls", :locals => { :node=>node, :opts => opts }
  end

  def create_root_element_link(class_name, options={})
    opts= {:top_root=>false}.merge!(options)
    render :partial => "#{opts[:path]}/create_root", :locals => { :class_name => class_name, :opts=>opts }
  end

  # ans_tree(@pages, :class_name=>'Report', :id_field=>'id', :clean=>false)
  #
  # ans_tree(@pages, :admin=>true, :class_name=>'Report', :id_field=>:zip, :clean=>false)
  def ans_tree(tree, options= {})
    result= ''

    opts= {
      :node=>nil,         # node
      :admin=>false,      # render admin tree?
      :root=>false,       # is it root node? 
      :id_field=>'id',    # id field name, id by default
      :class_name=>nil,   # class of nested elements
      :path => 'ans',     # default view partials path
      :first=>false,      # first element flag
      :last=>false,       # last element flag
      :level=> 0,         # recursion level
      :clean=>true        # delete element from tree after rendering?
    }.merge!(options)

    node= opts[:node]
    root= opts[:root]

    # must be string
    opts[:id_field]= opts[:id_field].to_s
    # find class name
    opts[:class_name]= opts[:class_name] ? opts[:class_name].to_s.downcase : tree.first.class.to_s.downcase

    return create_root_element_link(opts[:class_name], opts) if tree.empty?

    unless node
      roots= tree.select{|elem| elem.parent_id.nil?}
      # find ids of first and last root node
      roots_first_id= roots.empty? ? nil : roots.first.id
      roots_last_id=  roots.empty? ? nil : roots.last.id
      
      # render roots
      roots.each do |root|
        is_first= (root.id==roots_first_id)
        is_last= (root.id==roots_last_id)
        _opts = opts.merge({:node=>root, :root=>true, :level=>opts[:level].next, :first=>is_first, :last=>is_last})
        result<< ans_tree(tree, _opts)
      end
    else
      res= ''
      controls= ''
      childs_res= ''

      # select childs
      childs= tree.select{|elem| elem.parent_id == node.id}
      opts.merge!({:has_childs=>childs.blank?})

      # admin controls
      if opts[:admin]
        c = ans_controls(node, opts)
        controls= content_tag(:span, c, :class=>:controls)
      end

      # find id of first and last node
      childs_first_id= childs.empty? ? nil : childs.first.id
      childs_last_id=  childs.empty? ? nil : childs.last.id

      # render childs
      childs.each do |elem|
        is_first= (elem.id==childs_first_id)
        is_last= (elem.id==childs_last_id)
        _opts = opts.merge({:node=>elem, :root=>false, :level=>opts[:level].next, :first=>is_first, :last=>is_last})
        childs_res << ans_tree(tree, _opts)
      end

      # build views
      childs_res= childs_res.blank? ? '' : render(:partial=>"#{opts[:path]}/nested_set", :locals=>{:parent=>node, :childs=>childs_res})
      link= render(:partial=>"#{opts[:path]}/link", :locals=>{:node=>node, :opts=>opts, :root=>root, :controls=>controls})
      res= render(:partial=>"#{opts[:path]}/nested_set_item",  :locals=>{:node=>node, :link=>link, :childs=>childs_res})

      # delete current node from tree if you want
      # recursively moving by tree is 25%+ faster
      tree.delete(node) if opts[:clean]

      result << res
    end
    
    # decorate with 'create root' links
    if opts[:level].zero?
      top_root= create_root_element_link(opts[:class_name], opts.merge({:top_root=>true})) 
      result=   top_root + raw(result)
      result << create_root_element_link(opts[:class_name], opts)
    end
    
    result
  end#ans_tree

end
