# Be sure to restart your server when you modify this file.

CtmdbWeb::Application.config.session_store :active_record_store, key: '_ctmdbweb_session'

# protected attributes breaks new session creation, grrrr
ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id
