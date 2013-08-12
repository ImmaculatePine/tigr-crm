Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_APP_ID'], ENV['TWITTER_APP_SECRET']
  provider :yandex, ENV['YANDEX_APP_ID'], ENV['YANDEX_APP_SECRET']
  provider :google_oauth2, ENV['GOOGLE_APP_ID'], ENV['GOOGLE_APP_SECRET'], { access_type: "offline", approval_prompt: "" }
  provider :vkontakte, ENV['VKONTAKTE_APP_ID'], ENV['VKONTAKTE_APP_SECRET'], {scope: 'notify'}
end