if Rails.env.development?
  Que.wake_interval = 5.seconds
else
  Que.wake_interval = 15.seconds
end
