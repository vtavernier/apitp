(function($){
  $(function() {
    $('.upload-notify-input').on('change', function(event) {
      var target = $(this).closest('form').find('.upload-notify-target');
      // Update file name in button
      var btnLabel = target.val().split(" ")[0];
      if (this.files.length > 0) {
        btnLabel += " " + this.files[0].name;
      }
      target.val(btnLabel);
      target.attr('data-disable-with', btnLabel);
      // Update button enabled state
      var valid = this.files.length === 1 && this.files[0].size <= $(this).attr('data-max-size');
      target.attr("disabled", !valid);
      // Validate file size
      if (this.files.length > 0 && !valid) {
        alert($(this).attr('data-max-size-alert'));
      }
    });

    $('.upload-notify-target').attr('disabled', true);
  });
})(jQuery);
