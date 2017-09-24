class UserProjectPolicy < ProjectPolicy
  class Scope < Scope
    def resolve
      super
    end
  end
end
