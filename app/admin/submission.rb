ActiveAdmin.register Submission do
  permit_params :project_id, :user_id, :team_id, :file, :created_at

  controller do
    def update
      if params[:submission][:file].nil?
        params[:submission].delete(:file)
      end
      super
    end

    def destroy
      destroy! do |format|
        format.html { redirect_to admin_project_path(resource.project) }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :project, include_blank: false
      f.input :user,
              include_blank: false,
              collection: UserProject
                              .includes(:user)
                              .sort_by { |up| up.user.name }
                              .group_by { |up| up.user_id }
                              .map { |user_id, up|
                                [ up.first.user.name_email, user_id, :'data-projects' => up.collect(&:id).join(',') ] }
      f.input :team,
              include_blank: (not Rails.configuration.x.apitp.team_submissions),
              collection: Team
                            .includes(:team_memberships)
                            .includes(:users)
                            .map { |team| [ team.users.collect(&:name_email).join(' | '), team.id, :'data-group' => team.group_id ] }
                            .sort_by(&:first)
      f.input :file, as: :file
      if not f.object.new_record?
        f.input :created_at
      end
    end
    f.actions
  end
end
