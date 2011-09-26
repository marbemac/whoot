(function($, amplify) {

  $(function() {

    /*
     * Handles page gets.
     * Can handle JSON or XML response. Transforms XML response into JSON.
     */
    amplify.request.define("pageGet", "ajax", {
      type: 'GET',
      url: "{url}",
      decoder: function(data, status, xhr, success, error) {
        // Lets check if it's already an object
        if ($.isPlainObject(data))
          success(data);
        else {
          // Else parse the XML into an object
          var params = {};
          $(data).find('application').children().each(function() {
            if ($.trim($(this).text()).length > 0) {
              params[this.tagName] = $(this).text();
            }
          })

          if (params.result && params.result == 'success')
            params['pageRefresh'] = true;
          success(params);
        }
      }
    });


    /*
     * Handles actions that use PUT (updates).
     */
    amplify.request.define("putAction", "ajax", {
      type: "PUT",
      url: "{url}",
      dataType: 'json'
    });

    /*
     * Handles actions that use DELETE (destroy).
     */
    amplify.request.define("deleteAction", "ajax", {
      type: "DELETE",
      url: "{url}",
      dataType: 'json'
    });

    /*
     * Handles actions that use POST (votes, etc).
     */
    amplify.request.define("postAction", "ajax", {
      type: "POST",
      url: "{url}",
      dataType: 'json'
    });

    /*
     * Handles actions that use GET (topic edit form).
     */
    amplify.request.define("getAction", "ajax", {
      type: "GET",
      url: "{url}",
      dataType: 'json'
    });

    /*
     * Handles form submissions.
     */
    amplify.request.define("formSubmit", "ajax", {
      type: 'POST',
      url: "{url}",
      dataType: 'json'
    });

  });

}(jQuery, amplify) );