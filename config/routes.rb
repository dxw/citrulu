SimpleFrontEndTesting::Application.routes.draw do
  match '*path' => redirect('/')
end
