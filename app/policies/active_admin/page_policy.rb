module ActiveAdmin
  class PagePolicy < ApplicationPolicy
    class Scope < Struct.new(:user, :scope)
      def resolve
        scope
      end
    end

    def show?
      case record.name
        when 'Dashboard'
          user.admin?
        when 'Que'
          user.super_admin?
        else
          false
      end
    end

    def move_submissions?
      case record.name
        when 'Dashboard'
          user.super_admin?
        else
          false
      end
    end
  end
end