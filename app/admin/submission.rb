ActiveAdmin.register Submission do
  menu false

  controller do
    actions :destroy

    def destroy
      destroy! do |format|
        format.html { redirect_to admin_project_path(resource.project) }
      end
    end
  end
end
