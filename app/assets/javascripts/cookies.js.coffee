window.createCookie = (name,value,days) ->
        if days
                date = new Date()
                date.setTime(date.getTime() + (days * 24 * 60 * 60 * 365))
                expires = "; expires=" + date.toGMTString()
        else
                expires = ""
        document.cookie = name + "=" + value + expires + "; path=/";

window.readCookie = (name) ->
        nameEQ = name + "="
        cookie_array = document.cookie.split(';')
        for value in cookie_array
                value = value.substring(1, value.length) while (value.charAt(0) == ' ')
                return value.substring(nameEQ.length, value.length) if value.indexOf(nameEQ) == 0

window.eraseCookie = (name) ->
        createCookie(name,"",-1)
