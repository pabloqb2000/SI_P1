window.onload = init;

function init(){
    const interval = setInterval(function(){
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
             document.getElementById("users").innerHTML = "Users: " + this.responseText;
            }
          };
        xhttp.open("GET", "random_number");
        xhttp.send();
    }, 3000);

    var email_input = document.getElementById("email");
    var email_message = document.getElementById("email_popup");

    email_input.onfocus = function() {
        email_message.style.display = "block";
    }
    email_input.onblur = function() {
        var re_email = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        if(email_input.value.match(re_email)) {
            email_message.style.display = "none";
        }
    }

    email_input.onkeyup = function() {
        var re_email = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        if(email_input.value.match(re_email)) {
            email_message.style.color = "green";
        } else {
            email_message.style.color = "red";
        }
    }

    var user_input = document.getElementById("username");
    var user_message = document.getElementById("user_popup");

    user_input.onfocus = function() {
        user_message.style.display = "block";
    }
    user_input.onblur = function() {
        var re_user = /^[a-zA-Z0-9]+$/;
        if(user_input.value.length >= 6 && user_input.value.match(re_user)) {
            user_message.style.display = "none";
        }
    }

    user_input.onkeyup = function() {
        var re_user = /^[a-zA-Z0-9]+$/;
        if(user_input.value.length >= 6 && user_input.value.match(re_user)) {
            user_message.style.color = "green";
        } else {
            user_message.style.color = "red";
        }
    }

    var pwd_input = document.getElementById("password");
    var pwd_input_confirm = document.getElementById("confirmation");
    var confirmation_message = document.getElementById("cfm_popup");

    pwd_input_confirm.onfocus = function() {
        confirmation_message.style.display = "block";
    }
    pwd_input_confirm.onblur = function() {
        if(pwd_input.value.localeCompare(pwd_input_confirm.value) == 0) {
            confirmation_message.style.display = "none";
        }
    }

    pwd_input_confirm.onkeyup = function() {
        if(pwd_input.value.localeCompare(pwd_input_confirm.value) == 0) {
            confirmation_message.style.color = "green";
        } else {
            confirmation_message.style.color = "red";
        }
    }

    var card_input = document.getElementById("creditcard");
    var card_message = document.getElementById("card_popup");

    card_input.onfocus = function() {
        card_message.style.display = "block";
    }
    card_input.onblur = function() {
        var re_card = /^[0-9]+$/
        if(card_input.value.length == 16 && card_input.value.match(re_card)) {
            card_message.style.display = "none";
        }
    }

    card_input.onkeyup = function() {
        var re_card = /^[0-9]+$/
        if(card_input.value.length == 16 && card_input.value.match(re_card)) {
            card_message.style.color = "green";
        } else {
            card_message.style.color = "red";
        }
    }

    var dir_input = document.getElementById("direction");
    var dir_message = document.getElementById("dir_popup");

    dir_input.onfocus = function() {
        dir_message.style.display = "block";
    }
    dir_input.onblur = function() {
        if(dir_input.value.length <= 50) {
            dir_message.style.display = "none";
        }
    }

    dir_input.onkeyup = function() {
        if(dir_input.value.length <= 50) {
            dir_message.style.color = "green";
        } else {
            dir_message.style.color = "red";
        }
    }
}

$(document).ready(function() {

    $('input[id=password]').keyup(function() {
        var pswd = $(this).val();
        var bar = document.getElementById("progress_bar");
        var width = 0;

        if ( pswd.length < 8 ) {
            $('#length').removeClass('valid').addClass('invalid');
        } else {
            $('#length').removeClass('invalid').addClass('valid');
            width += 25;
        }
        //validate letter
        if ( pswd.match(/[A-z]/) ) {
            $('#letter').removeClass('invalid').addClass('valid');
            width += 25;
        } else {
            $('#letter').removeClass('valid').addClass('invalid');
        }

        //validate capital letter
        if ( pswd.match(/[A-Z]/) ) {
            $('#capital').removeClass('invalid').addClass('valid');
            width += 25;
        } else {
            $('#capital').removeClass('valid').addClass('invalid');
        }

        //validate number
        if ( pswd.match(/\d/) ) {
            $('#number').removeClass('invalid').addClass('valid');
            width += 25;
        } else {
            $('#number').removeClass('valid').addClass('invalid');
        }
        bar.style.width = width + "%";
        bar.innerHTML = width + "%";
    }).focus(function() {
        $('#pswd_info').show();
    }).blur(function() {
        $('#pswd_info').hide();
    });
});