'use strict'

function uploadFile() {
    document.getElementById('confirm_upload_to_cloud').style.display = 'block';

    document.getElementById('form_button').style.display = 'none';
    document.getElementById('yes').onclick = function() {
        document.getElementById('form_button').style.display = 'block';
        document.getElementById('confirm_upload_to_cloud').style.display = 'none';
        let temp = document.getElementById('file-upload-to-cloud');
        let file = temp.files[0];
        let form = new FormData();
        form.append('data', file);
        let settings = {
            'url': '/api/3/action/uploadFileToCloud',
            'method': 'POST',
            'timeout': 0,
            'processData': false,
            'mimeType': 'multipart/form-data',
            'contentType': false,
            'data': form
        };
        $.ajax(settings).done(function(response) {
            let url = JSON.parse(response);

            if (url.result == null) {
                alert('FAILED, check your permission!')
            } else {
                $('#field-image-url').val(url.result);
                $('#change').click();
                $('#file-upload-to-cloud').val('');
            }
        });
    };
    document.getElementById('no').onclick = function() {
        document.getElementById('confirm_upload_to_cloud').style.display = 'none';
        document.getElementById('form_button').style.display = 'block';
        $('#file-upload-to-cloud').val('');
    };
}