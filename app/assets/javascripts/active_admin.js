//= require active_admin/base

(function($) {
  $(function() {
    function updateTeamGroupMemberships(currentId) {
      $('#team_group_membership_ids_input').find('li.choice').each(function (i, item) {
        var input = $(item).find('input[type=checkbox]');
        if (input.attr('data-group-id') === currentId) {
          var checked = input.data('checked-status');
          if (typeof checked === 'undefined') {
            input.data('checked-status', input.prop('checked'));
          } else {
            input.prop('checked', checked);
          }
          $(item).show();
        } else {
          $(item).hide();
          input.data('checked-status', input.prop('checked'));
          input.prop('checked', false);
        }
      });
    }

    var input = $('#team_group_id');
    if (input.length) {
      input.on('change', function (event) {
        updateTeamGroupMemberships($(this).val());
      });
      updateTeamGroupMemberships(input.val());
    }
  });
})(jQuery);
