var data = {
    searchactive: false,
    showfav: false,
    selectedveh: null,
    action: "einparken"
}

jQuery(document).ready(function(){
    window.addEventListener('message', function(e) {    
        var event = e.data
        if (event.action == "show") {
            if (event.state) {
                $('body').css('display', 'flex');
                $(".currentgarage").text(event.name);
                $.post('http://dinerov_garage/enable-parking', JSON.stringify({}));
            } else {
                $('body').css('display', 'none');
            }
        } else if (event.action == "addCar") {
            AddCar(event.model, event.plate, event.nickname, event.isFav);     
        }
    });
});

function resetdata() {
    data.searchactive = false;
    data.showfav = false;
    data.selectedveh = null;
    data.action = "einparken"

    /*searchbar*/
    $(".search").css({'display':'none'});
    var popup = document.getElementById('searchbar')
    var input = document.getElementById('search')
    input.value = ""
    popup.classList.remove('active');

    /*favcars*/
    showonlyfavcars(false)
    var nutte = document.getElementById('favtoggle')
    nutte.innerHTML = '<i class="far fa-star"></i>'

    /*veh*/
    var vehicles = document.getElementById("vehlist");
    vehicles.innerHTML = '';

    /*actionbtn*/
    var parkaction = document.getElementById('parkaction')
    parkaction.classList.remove('active');

    var parkbtn = document.getElementById('parkbtntxt');
    parkbtn.innerText = "Einparken"

    $(".action").removeClass("actionselected");
    $("#parkin").addClass("actionselected");

    $(".placeholder").show();
}

$( ".close" ).click(function() {
    $.post('http://dinerov_garage/escape', JSON.stringify({}));
    $('body').css('display', 'none');
    resetdata()
});

function actionselect(elem,action) {
    if (action != data.action) {
        var parkaction = document.getElementById('parkaction')
        parkaction.classList.remove('active');
        var parkbtn = document.getElementById('parkbtntxt');
        resetdata()
        $(".action").removeClass("actionselected");
        $(elem).addClass("actionselected");    

        data.action = action;

        if (action == "einparken") {
            parkbtn.innerText = "Einparken"
            $.post('http://dinerov_garage/enable-parking', JSON.stringify({}));
            $(".placeholder").text("Keine Fahrzeuge in der Nähe zum einparken");
        } else if (action == "ausparken") {
            parkbtn.innerText = "Ausparken"
            $.post('http://dinerov_garage/enable-parkout', JSON.stringify({}));
            $(".placeholder").text("Du hast keine Fahrzeuge in der Garage");
        }
    }
}

function park() {
    if(data.selectedveh != null) {
        if(data.action == "einparken") {
            $.post('http://dinerov_garage/park-in', JSON.stringify({plate: data.selectedveh}));
        } else if (data.action == "ausparken") {
            $.post('http://dinerov_garage/park-out', JSON.stringify({plate: data.selectedveh}));
        }
        $.post('http://dinerov_garage/escape', JSON.stringify({}));
        $('body').css('display', 'none');
        resetdata()    
    }
}

function togglefav(elem) {
    if (data.showfav) {
        elem.innerHTML = '<i class="far fa-star"></i>'
        data.showfav = false
        showonlyfavcars(false)
    } else {
        elem.innerHTML = '<i class="fas fa-star"></i>'
        data.showfav = true
        showonlyfavcars(true)
    }
}

function togglesearchbar() {
    var popup = document.getElementById('searchbar')
    var input = document.getElementById('search')
    input.value = ""

    popup.classList.toggle('active');
    if (data.searchactive) {
        $(".search").css({'display':'none'});
        data.searchactive = false
    } else {
        $(".search").css({'display':'block'});
        data.searchactive = true
    }
    searchfunction()
}

function showonlyfavcars(state) {
    if (state) {
        ul = document.getElementById("vehlist");
        li = ul.getElementsByClassName('carsetfav');

        for (i = 0; i < li.length; i++) {
            if (li[i].innerHTML == '<i class="far fa-star" aria-hidden="true"></i>') {
                li[i].parentElement.style.display = "none";
            } else {
                li[i].parentElement.style.display = "flex";
            }
        }
    } else {
        ul = document.getElementById("vehlist");
        li = ul.getElementsByClassName('carsetfav');

        for (i = 0; i < li.length; i++) {
            li[i].parentElement.style.display = "flex";
        }
    }
}

function searchfunction() {
    input = document.getElementById('search');
    filter = input.value.toUpperCase();
    ul = document.getElementById("vehlist");
    li = ul.getElementsByClassName('carinformations');
    ta = ul.getElementsByClassName('carsetfav');

    if(data.showfav) {
        for (i = 0; i < li.length; i++) {
            txtValue = li[i].innerText;
            if(ta[i].innerHTML == '<i class="fas fa-star" aria-hidden="true"></i>') {
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    li[i].parentElement.style.display = "flex";
                } else {
                    li[i].parentElement.style.display = "none";
                }
            }
        }
    } else {
        for (i = 0; i < li.length; i++) {
            txtValue = li[i].innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                li[i].parentElement.style.display = "flex";
            } else {
                li[i].parentElement.style.display = "none";
            }
        }
    }
}

function togglecarfav(elem,plate) {
    if (elem.innerHTML == '<i class="far fa-star" aria-hidden="true"></i>') {
        elem.innerHTML = '<i class="fas fa-star" aria-hidden="true"></i>'
        $.post('http://dinerov_garage/setvehfav', JSON.stringify({
            plate: plate,
            state: true
        }));
    } else {
        elem.innerHTML = '<i class="far fa-star" aria-hidden="true"></i>'
        $.post('http://dinerov_garage/setvehfav', JSON.stringify({
            plate: plate,
            state: false
        }));
    }
}

function selectveh(elem,plate) {
    if (data.selectedveh != plate) {
        $(".carcontainer").css({'color':'white'});
        $(elem.parentElement).css({'color':'var(--maincolor)'});
        var parkaction = document.getElementById('parkaction')
        parkaction.classList.add('active');
        data.selectedveh = plate
    }
}

function showrenamewindow(elem, plate) {
    $(elem.parentElement).append
    (`
    <div class="renamewindow">
        <i class="fas fa-arrow-left"onclick="vehrenamewindowclose(this)"></i><txt>Fahrzeug umbenennen</txt>
        <input maxlength="10" class="renameinput" id="`+ plate +`"></input>
        <div class="rename" onclick="renamevehiclenickname(this,'`+ plate +`')"><i class="far fa-check-circle"></i></div>
    </div>
    `);
    console.log(plate)
}

function vehrenamewindowclose(elem) {
    elem.parentElement.parentElement.removeChild(elem.parentElement)
}

function AddCar(model, plate, nickname, isFav) {
    $(".placeholder").hide();
    if (isFav) {
        $("#vehlist").prepend
        (`
        <div class="carcontainer">
            <i class="fas fa-car"></i>
            <div class="carinformations">
                <div class="model">`+ model +`</div>
                <div class="plate">`+ plate +`</div>
                <div class="nickname">`+ nickname +`</div>
            </div>
            <div class="carfl" onclick="selectveh(this,'`+ plate +`')"></div>
            <div class="carsetfav" onclick="togglecarfav(this,'`+ plate +`')"><i class="fas fa-star"></i></div>
            <div class="carshowrename" onclick="showrenamewindow(this,'`+ plate +`')"><i class="fas fa-pencil-alt"></i></div>
        </div>
        `);    
    } else {
        $("#vehlist").append
        (`
        <div class="carcontainer">
            <i class="fas fa-car"></i>
            <div class="carinformations">
                <div class="model">`+ model +`</div>
                <div class="plate">`+ plate +`</div>
                <div class="nickname">`+ nickname +`</div>
            </div>
            <div class="carfl" onclick="selectveh(this,'`+ plate +`')"></div>
            <div class="carsetfav" onclick="togglecarfav(this,'`+ plate +`')"><i class="far fa-star"></i></div>
            <div class="carshowrename" onclick="showrenamewindow(this,'`+ plate +`')"><i class="fas fa-pencil-alt"></i></div>
        </div>
        `);    
    }
}

function renamevehiclenickname(elem,plate) {
    if (document.getElementById(plate).value != "") {
        $.post('http://dinerov_garage/rename', JSON.stringify({
            plate: plate,
            nickname: document.getElementById(plate).value
        }));

        var abudabi = elem.parentElement.parentElement.getElementsByClassName("nickname")
        abudabi[0].innerText = document.getElementById(plate).value;
        elem.parentElement.parentElement.removeChild(elem.parentElement)
    }
}        