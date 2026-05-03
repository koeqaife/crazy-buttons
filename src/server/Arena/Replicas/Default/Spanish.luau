--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local Spanish: DictTemplate = {
    in_place = {
        ["You"] = { text = "Tu" },
        ["Attack"] = { text = "Atacar" },
        ["Defense"] = { text = "Defender" },
        ["Trust"] = { text = "Confiar" },

        ["Yes"] = { text = "Sí" },
        ["No"] = { text = "No" },

        ["BLUE"] = { text = "AZUL" },
        ["RED"] = { text = "ROJO" },
        ["YELLOW"] = { text = "AMARILLO" },
        ["GREEN"] = { text = "VERDE" },
        ["PINK"] = { text = "ROSA" },

        ["Blue"] = { text = "Azul" },
        ["Red"] = { text = "Rojo" },
        ["Yellow"] = { text = "Amarillo" },
        ["Green"] = { text = "Verde" },
        ["Pink"] = { text = "Rosa" },

        ["blue"] = { text = "azul" },
        ["red"] = { text = "rojo" },
        ["yellow"] = { text = "amarillo" },
        ["green"] = { text = "verde" },
        ["pink"] = { text = "rosa" },

        ["Vote to Skip"] = { text = "Vota para saltarlo" },

        ["Accident Die"] = { text = "Muerte accidental" },
        ["Any button can kill you with chance 4%"] = { text = "Cualquier botón puede matarte con un 4% de probabilidad" },

        ["Alien Language"] = { text = "Idioma Alienígena" },
        ["I will be talking with you on alien language"] = { text = "Te hablaré en idioma alienígena" },

        ["Mixed Colors"] = { text = "Colores Mezclados" },
        ["Button colors will mix every time now"] = { text = "Los colores de los botones se mezclarán siempre ahora" },

        ["No Chat"] = { text = "Sin Chat" },
        ["Chat will be disabled during rounds"] = { text = "El chat se desactivará durante las rondas" },

        ["Random Buttons"] = { text = "Botones Aleatorios" },
        ["Buttons will be located on random positions on the map"] = { text = "Los botones estarán en posiciones aleatorias del mapa" },

        ["Random Lives"] = { text = "Vidas Aleatorias" },
        ["Your lives amount will be randomized"] = { text = "Tu cantidad de vidas será aleatoria" },

        ["Simon says... select "] = { text = "Simón dice... elige " },
        ["Simon says... do not select "] = { text = "Simón dice... no elijas " },
        ["Simon says, select "] = { text = "Simón dice, elige " },
        ["Simon says, do not select "] = { text = "Simón dice, no elijas " },

        ["Select "] = { text = "Elige " },
        ["Do not select "] = { text = "No elijas " },

        ["Now... select "] = { text = "Ahora... elige " },
        ["Now... do not select "] = { text = "Ahora... no elijas " },
        ["Simply select "] = { text = "Simplemente elige " },
        ["My name is Simon, select "] = { text = "Mi nombre es Simón, elige " },
        ["Simon thinks you should select "] = { text = "Simón cree que deberías elegir " },

        ["Simon says... select the color of the sky"] = { text = "Simón dice... elige el color del cielo" },
        ["Simon says... select the color of a banana"] = { text = "Simón dice... elige el color de un plátano" },
        ["Simon says... select the color of a ruby"] = { text = "Simón dice... elige el color de un rubí" },
        ["Select the color of the sky"] = { text = "Elige el color del cielo" },
        ["Select the color of a banana"] = { text = "Elige el color de un plátano" },
        ["Select the color of a ruby"] = { text = "Elige el color de un rubí" },

        ["Do not change your selection"] = { text = "No cambies tu elección" },
        ["Simply not change your selection"] = { text = "Simplemente no cambies tu elección" },
        ["Change your selection"] = { text = "Cambia tu elección" },
        ["Simon says... change your selection"] = { text = "Simón dice... cambia tu elección" },
        ["Simon says... do not change your selection"] = { text = "Simón dice... no cambies tu elección" },

        ["You had to select the color"] = { text = "Tenías que elegir el color" },
        ["Your selection had to be opposite"] = { text = "Tu elección debía ser la opuesta" },

        ["There was no 'Simon says' so you had to do the opposite of 'do not'"] = { text = "No hubo 'Simón dice', así que debías hacer lo opuesto de 'no'" },
        ["There was no 'Simon says' so your selection had to be other color"] = { text = "No hubo 'Simón dice', así que debías elegir otro color" },
        ["Simply is not 'Simon says', so your selection had to be other color"] = { text = "'Simplemente' no es 'Simón dice', necesitabas otro color" },
        ["His name is Simon, but there was no 'Simon says'"] = { text = "Se llama Simón, pero no hubo 'Simón dice'" },
        ["Simon thinks but he didn't say 'Simon says'"] = { text = "Simón piensa, pero no dijo 'Simón dice'" },

        ["The color of the sky is blue"] = { text = "El color del cielo es azul" },
        ["The color of banana is yellow"] = { text = "El color del plátano es amarillo" },
        ["The color of ruby is red"] = { text = "El color del rubí es rojo" },
        ["There was no 'Simon says' so your selection had to be NOT blue"] = { text = "No hubo 'Simón dice', así que tu elección debía ser NO azul" },
        ["There was no 'Simon says' so your selection had to be NOT yellow"] = { text = "No hubo 'Simón dice', así que tu elección debía ser NO amarillo" },
        ["There was no 'Simon says' so your selection had to be NOT red"] = { text = "No hubo 'Simón dice', así que tu elección debía ser NO rojo" },

        ["There was no 'Simon says' so you had to do the opposite of 'simply not'"] = { text = "No hubo 'Simón dice', así que debías hacer lo opuesto a 'simplemente no'" },
        ["There was no 'Simon says' so you had to not click anything"] = { text = "No hubo 'Simón dice', así que no debías tocar nada" },
        ["You had to press any button"] = { text = "Tenías que presionar cualquier botón" },
        ["You had to not press any button"] = { text = "No tenías que presionar ningún botón" },

        ["Press button to move"] = { text = "Pulsa el botón para hacer tu movimiento" },
        ["Wait for them to move"] = { text = "Espera a que hagan su movimiento" },
        ["Remember combination"] = { text = "Recuerda la combinación" },
        ["Repeat combination (do your best)"] = { text = "Repite la combinación (lo mejor que puedas)" },
        ["Click as fast as possible on green"] = { text = "Haz clic en el verde lo más rápido posible" },
        ["One button kills"] = { text = "Un botón mata" },
        ["One button rewards"] = { text = "Un botón da recompensa" },
        ["Equip and press on other player to kill"] = { text = "Equipa y pulsa sobre otro jugador para matar" },
        ["When 4 subjects are left, you get unlinked"] = { text = "Cuando quedan 4 jugadores, dejáis de estar vinculados" },
        ["You lose life if you answer is wrong"] = { text = "Pierdes una vida si la respuesta es incorrecta" },
        ["Simon will try to trick you"] = { text = "Simon intentará engañarte" },
        ["People vote for who to eliminate"] = { text = "Los jugadores votan a quién eliminar" },
        ["One button kills, one button rewards"] = { text = "Un botón mata, otro da recompensa" },
        ["Like the game if you enjoy playing!"] = { text = "¡Dale a \"Me gusta\" al juego si te gusta!" }
    },
    --| MISC |--
    misc = {
        error_occurred = { text = "Se ha producido un error; no podemos continuar", face = "dead" },
        purchase_not_processed = { text = "Tu compra fue procesada, pero no puede usarse ahora. La próxima es gratis", face = "nerd" },
        purchase_processed = { text = "¡Tu compra ha sido procesada!", face = "nerd" },
        players_left = { text = "Quedan {count} sujetos", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Están respondiendo a una pregunta secreta...", face = "shy" },
        question_for_you = { text = "Tengo una pregunta para ti", face = "normal" },
        question_like_aliens = { text = "¿Te gustan los alienígenas?", face = "alien" },
        oh_no = { text = "Oh no...", face = "no_mouth" },
        not_nice = { text = "Eso no es amable.....", face = "unamused" },
        happy_face = { text = ":D", face = "happy" },
        that_is_cool = { text = "Eso es genial", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = {
            text = "{p1} y {p2} jugarán a Atacar, Defender, Confiar",
            requiredKeys = {"p1", "p2"},
            face = "att_def_tru_icon"
        },
        rules_are_simple = { text = "Las reglas son simples", face = "happy" },
        rules = { text = "Atacar vence a Confiar, Defender vence a Atacar, Confiar vence a Defender", face = "nerd" },
        loser_eliminate = { text = "El perdedor perderá una vida", face = "dead" },
        choose_your_move = { text = "Elige tu movimiento", face = "normal" },
        waiting_for_move = {
            text = "Esperando a que {p1} y {p2} elijan...",
            requiredKeys = {"p1", "p2"},
            face = "normal"
        },
        both_did_not_move = { text = "Ambos sujetos no se movieron", face = "dead" },
        you_both_chose = { text = "Ambos eligieron {btn}", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "Ambos eligieron {btn}", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "Es un empate, elijan de nuevo", face = "shy" },
        tie_they_choose_again = { text = "Es un empate, elegirán de nuevo", face = "shy" },

        att_def = { text = "Se defendieron de tu ataque", face = "dead" },
        def_att = { text = "Te defendiste de su ataque", face = "happy" },

        att_trust = { text = "Confiaron demasiado y fueron atacados", face = "happy" },
        trust_att = { text = "Te atacaron mientras intentabas confiar", face = "dead" },

        def_trust = { text = "Te resbalaste al intentar defenderte del aire", face = "dead" },
        trust_def = { text = "Se resbalaron al intentar defenderse del aire", face = "happy" },

        won_against = { text = "¡{won} le ganó a {lost}!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "Tienen una prueba engañosa con un botón", face = "click_button_icon" },
        reaction_test = { text = "Ahora lee y presiona el botón si lo dice", face = "click_button_icon" },
        not_much_time = { text = "Pero solo tienes dos segundos para reaccionar", face = "no_mouth" },
        be_ready = { text = "Prepárate", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },

        button_says_truth = { text = "EL BOTÓN DICE LA VERDAD", face = "click_button_icon" },
        button_says_lie = { text = "EL BOTÓN MIENTE", face = "click_button_icon" },

        you_had_to_click = { text = "Deberías haber presionado", face = "dead" },
        you_had_to_not_click = { text = "No deberías haber presionado", face = "dead" },
        you_survived = { text = "Sobreviviste", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "Tendrán que presionar el botón primero", face = "click_button_icon" },
        last_num_eliminate = { text = "El último en presionar perderá una vida", face = "dead" },
        click_faster = { text = "Presiona más rápido que los demás", face = "scared" },
        you_have_to_click = { text = "Prepárate para presionar lo más rápido posible", face = "click_button_icon" },

        you_did_not_click = { text = "No presionaste", face = "angry" },
        you_clicked_too_slow = { text = "Eso fue lento", face = "scared" },

        you_survived = { text = "Sobreviviste", face = "happy" },
        you_are_eliminated = { text = "Perdiste una vida", face = "dead" },
        wait_for_others = { text = "Espera a que los demás presionen", face = "dead" },
        wait_for_green = { text = "Espera hasta que el botón se ponga verde", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Están viendo si recuerdan el color", icon = "color_event_icon" },
        for_dead_start = { text = "Se les pidió que recordaran un color", face = "color_event_icon" },
        you_remember_color = { text = "¿Recuerdas el color que elegiste antes?", face = "color_event_icon" },
        lets_check = { text = "Vamos a probar tu memoria", face = "shy" },

        did_not_choose = { text = "No elegiste un color", face = "normal" },
        so_lucky = { text = "Qué suerte", face = "happy" },

        which_one_you_chose = { text = "¿Recuerdas cuál elegiste antes?", face = "nerd" },
        wrong_color = { text = "Color incorrecto", face = "dead" },
        correct_color = { text = "¡Correcto, lo recordaste!", face = "happy" },
        good_job = { text = "Buen trabajo", face = "shy" },

        about_to_show_colors = { text = "Te mostraré 3 colores", face = "color_event_icon" },
        remember_color = { text = "Elige el color y recuérdalo", face = "normal" },
        choose = { text = "Elige ahora", face = "nerd" },

        red = { text = "Muy interesante", face = "happy" },
        blue = { text = "El color del cielo, ya veo", face = "happy" },
        pink = { text = "¿Por qué? Aunque parece delicioso", face = "happy" },
        yellow = { text = "¿Te gustan las plátanos?", face = "happy" },
        green = { text = "El color de la naturaleza, buena elección", face = "happy" },
        nothing = { text = "¿Nada? Entonces iremos con {color}", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Ahora repetirán la secuencia", face = "combo_event_icon" },
        repeat_after_me = { text = "Ahora tendrás que repetir la secuencia después de mí", face = "combo_event_icon" },
        players_to_eliminate = { text = "Los sujetos con más errores perderán una vida", face = "dead" },
        lets_start = { text = "Empecemos", face = "shy" },
        my_turn = { text = "Mi turno, observa bien", face = "normal" },
        your_turn = { text = "Tu turno", face = "nerd" },
        clicks_left = { text = "Faltan {num} clics", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Esperemos a que los demás terminen", face = "normal" },
        mistakes_count = { text = "Tienes {num} errores", requiredKeys = {"num"}, face = "normal" },
        lets_see = { text = "Veamos qué tenemos aquí", face = "scared" },

        you_eliminated = { text = "Eres uno de los que han perdido una vida", face = "dead" },
        you_survived = { text = "Sobreviviste", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "{p1} y {p2} jugarán un duelo mortal", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "El sujeto más rápido sobrevive", face = "normal" },
        you_did_not_click = { text = "No presionaste", face = "angry" },
        you_are_eliminated = { text = "Perdiste una vida", face = "dead" },
        good_job = { text = "Buen trabajo", face = "shy" },
        you_were_fast_enough = { text = "Fuiste lo suficientemente rápido", face = "happy" },
        you_are_slow = { text = "Fuiste demasiado lento", face = "dead" },
        won = { text = "{player} ganó este duelo", face = "happy", requiredKeys = {"player"} },
        wait_for_green = { text = "Espera hasta que el botón se ponga verde", face = { text = "..." } }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "Decidirán si presionar el botón o no", face = "even_odd_event_icon" },
        intro_alive = { text = "Decidirás si presionar el botón o no", face = "even_odd_event_icon" },
        intro_counting = { text = "Después, contaré las presiones", face = "nerd" },
        intro_odd = { text = "Si es impar, los que presionaron son eliminados", face = "even_odd_event_icon" },
        intro_even = { text = "Si es par, los que no presionaron son eliminados", face = "even_odd_event_icon" },

        remember_to_talk = { text = "Recuerda hablar con los demás", face = "shy" },

        time_to_count = { text = "Hora de contar", face = "scared" },
        player_clicked = { text = "{player} presionó", requiredKeys = {"player"}, face = "normal" },

        count_even = { text = "Es par", face = "normal" },
        count_odd = { text = "Es impar", face = "normal" },

        you_survived = { text = "Sobreviviste", face = "happy" },
        you_are_eliminated = { text = "Perdiste una vida", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "Aparecieron 100 botones", face = "laughing" },
        intro_ready = { text = "Prepárense para buscar", face = "happy" },
        intro_100_buttons = { text = "100 botones caerán del cielo", face = "scared" },
        intro_first_rewarded = { text = "Un botón te da algo genial", face = "shy" },
        good_luck = { text = "Buena suerte encontrándolo", face = "laughing" },
        you_found_god_btn = { text = "¡Encontraste el botón!", face = "happy" },
        someone_found_god_btn = { text = "{player} encontró el botón", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Nadie encontró el botón", face = "no_mouth" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Alguien recibirá un regalo", face = "laughing" },
        intro_alive_part1 = { text = "Un sujeto recibirá un regalo ahora", face = "happy" },
        intro_alive_part2 = { text = "Y será......", face = "scared" },
        dead_who_got = { text = "{player} recibió un regalo", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "¡Tú!", face = "happy" },
        you_got_tool_part2 = { text = "Ahí hay un botón gris, presiónalo", face = "shy" },
        you_got_tool_part3 = { text = "Y después haz clic en alguien que te caiga bien", face = "no_mouth" },
        you_got_tool_part4 = { text = "Aparecerá un confeti muy bonito", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "Ahora están felices con su regalo", face = "happy" },
        someone_got_tool_part3 = { text = "Es muy genial", face = "shy" },
        someone_got_tool_part4 = { text = "Esto es genial, ¿verdad?", face = "normal" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Voy a vincular a dos personas ahora", face = "scared" },
        intro_part2 = { text = "Si uno muere, el otro también", face = "dead" },
        intro_part3 = { text = "Veamos quién es", face = "normal" },
        first_player_is = { text = "El primer sujeto es...", face = "normal" },
        second_player_is = { text = "El segundo sujeto es...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "{player} hará una prueba de matemáticas", requiredKeys = {"player"}, face = "nerd" },

        intro_self_q1 = { text = "¿Te crees listo?", face = "nerd" },
        intro_self_q2 = { text = "Alguien morirá si piensa lo contrario", face = "scared" },

        intro_others_q1 = { text = "¿Crees que {player} es bueno en matemáticas?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Tendrás que averiguarlo", face = "shy" },

        calculate_this = { text = "Calcula esto ahora:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },

        is_player_smart = { text = "¿Es {player} lo bastante listo para calcular:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },

        you_answer_right = { text = "Tu respuesta fue correcta", face = "happy" },
        you_answer_wrong = { text = "Tu respuesta fue incorrecta", face = "scared" },

        you_not_believed = { text = "Pero nadie creyó en ti...", face = "dead" },
        you_had_to_answer = { text = "Tenías que responder...", face = "dead" },
        you_wrong_lucky = { text = "Te equivocaste, pero tuviste suerte", face = "happy" },
        you_wrong = { text = "Te equivocaste", face = "dead" },
        you_right = { text = "Tenías razón", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "Acaba de aparecer un laberinto", face = "normal" },
        intro_part2 = { text = "Hay exactamente 6 botones", face = "normal" },
        intro_part3 = { text = "Uno es peligroso, otro es útil", face = "scared" },
        intro_part4 = { text = "Buena suerte buscando", face = "happy" },
        somebody_awarded = { text = "Alguien fue premiado", face = "happy" },
        no_one_awarded = { text = "Nadie fue premiado", face = "no_mouth" },
    },

    --| OBBY EVENT |--
    obby = {
        intro_part1 = { text = "Acabo de poner un reto muy fácil", face = "normal" },
        intro_part2 = { text = "Hay un botón al final", face = "normal" },
        intro_part3 = { text = "Sé el primero en presionarlo para ganar algo", face = "scared" },
        intro_part4 = { text = "El último en presionarlo perderá una vida", face = "dead" },
        intro_part5 = { text = "No pierdas tu tiempo aquí", face = "dead" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Alguien aleatorio volverá a la vida ahora", face = "shy" },
        player_revived = { text = "Y es {player}", requiredKeys = {"player"}, face = "happy" },

        intro_vote_common = { text = "¿Quieren que alguien vuelva?", face = "shy" },
        intro_vote_candidate = { text = "Los sujetos decidirán si eres tú", face = "shy" },
        intro_dead_not_you = { text = "Alguien volverá", face = "shy" },
        intro_choose_wise = { text = "Incluso si no, tienes que elegir", face = "nerd" },

        you_are_revived = { text = "¡Dile hola a todos!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = {
            text = "Tendrán que sacrificarse por {p1} y {p2}",
            requiredKeys = {"p1", "p2"},
            face = "scared"
        },

        chosen_you_1 = { text = "Tu vida puede terminar ahora", face = "scared" },
        chosen_you_2 = { text = "Alguien tiene que sacrificarse por ti", face = "scared" },

        chosen_others_1 = { text = "{p1} y {p2} fueron elegidos.", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "¿Te sacrificarás para salvarlos?", face = "shy" },

        press_to_save = { text = "Presiona para salvarlos", face = "shy" },
        choice_cannot_be_undone = { text = "Tu elección no se puede deshacer", face = "dead" },

        you_are_eliminated = { text = "Perdiste una vida", face = "dead" },
        they_are_eliminated = { text = "Diles adiós", face = "scared" },

        you_are_saved = { text = "Estás a salvo ahora", face = "happy" },
        you_saved_them = { text = "Eres una persona muy amable", face = "dead" },
        they_were_saved = { text = "{p1} y {p2} ahora están bien", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "Están escuchando a Simón ahora", face = "nerd" },
        intro_alive_1 = { text = "Ahora soy Simón, sigue mis comandos", face = "shy" },
        intro_alive_2 = { text = "Haz lo opuesto si no dije 'Simón dice'", face = "nerd" },
        intro_alive_3 = { text = "Cuando diga 'elige', presiona el botón para que brille", face = "nerd" },
        intro_alive_4 = { text = "Empecemos con algo sencillo", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Sé amigo de {p2}, tendrás que dividir o robar", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} y {p2} tienen que dividir o robar", requiredKeys = {"p1","p2"}, face = "happy" },

        rule_both_split = { text = "Si ambos dividen, no pasa nada", face = "happy" },
        rule_one_steal = { text = "Si uno roba, el otro muere", face = "scared" },
        rule_both_steal = { text = "Si ambos roban, ambos mueren", face = "laughing" },
        rule_both_steal_others = { text = "Si ambos roban, ambos mueren", face = "laughing" },

        choose_wisely = { text = "Elige sabiamente", face = "nerd" },
        waiting_for_players = { text = "Esperando que los sujetos decidan", face = "normal" },

        both_steal = { text = "Ambos decidieron robar, ambos mueren", face = "laughing" },
        stealer_chosen = { text = "{stealer} decidió robar, {victim} pierde una vida", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Ambos decidieron dividir, ambos sobreviven", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "Tu botón es malo", face = "shy" },
        intro_killer_2 = { text = "Cualquiera que lo presione, muere", face = "scared" },
        intro_killer_3 = { text = "Convence a otros de presionarlo (el tuyo es malo)", face = "normal" },

        intro_saver_1 = { text = "Tu botón es muy normal", face = "shy" },
        intro_saver_2 = { text = "Cualquiera que lo presione, no muere", face = "happy" },
        intro_saver_3 = { text = "Convence a otros de presionarlo (el tuyo es bueno)", face = "normal" },

        intro_others_1 = { text = "Tienes que hablar con {p1} y {p2}", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "Uno de ellos tiene un botón que te mata", face = "normal" },
        intro_others_3 = { text = "Entonces, ¿a quién le crees?", face = "nerd" },

        lets_see = { text = "Veamos quién murió...", face = "normal" },

        result_no_choice = { text = "No elegiste un botón, moriste", face = "dead" },
        result_chose_died = { text = "Elegiste el botón de {p}, moriste", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "Elegiste el botón de {p}, estás a salvo", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "Están votando a quién eliminar", face = "shy" },

        intro_common_1 = { text = "Hora de votar por eliminación", face = "normal" },
        intro_candidate_fate = { text = "Otros decidirán tu destino.", face = "scared" },
        intro_choose_wise = { text = "Elige a alguien que te caiga mal", face = "happy" },

        candidate_line_1 = { text = "Veo que están votando", face = "normal" },
        candidate_line_2 = { text = "El más votado será eliminado", face = "shy" },
        candidate_line_3 = { text = "¿Qué crees, les agradas?", face = "normal" },
        candidate_line_4 = { text = "Imagina que no", face = "scared" },
        candidate_line_5 = { text = "Mantente fuerte", face = "normal" },
        candidate_line_6 = { text = "Sigue adelante en el experimento", face = "shy" },
        candidate_line_7 = { text = "Buena suerte", face = "scared" },

        you_eliminated = { text = "Perdiste una vida... lo siento", face = "dead" },
        player_eliminated = { text = "{player} perdió una vida", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Bienvenido, {player}", requiredKeys = {"player"}, face = "happy" },
        intro_button_experiment = { text = "Has entrado en el Buttons Experiment", face = "normal" },
        intro_tested = { text = "Te enfrentarás a una serie de pruebas", face = "scared" },
        intro_easy_hard = { text = "Algunas serán sencillas. Otras no", face = "dead" },
        intro_begin = { text = "Mantente alerta. Comencemos", face = "happy" },

        intro_special = { text = "Ahora tenemos rondas especiales", face = "alien" },
        intro_special2 = { text = "Se presentarán tres efectos diferentes", face = "alien" },
        special_text = { text = "{text}", face = "scared", requiredKeys = {"text"} },
        special_text2 = { text = "{text}", face = "nerd", requiredKeys = {"text"} },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "{survivor} llegó hasta el final", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "¡Muy buen desempeño!", face = "shy" },
        survivor_congratulations = { text = "Hay un botón, puedes presionarlo", face = "happy" },
    },

    --| FIVE BUTTONS EVENT |--
    five_buttons = {
        intro_part1 = { text = "Aparecerán cinco botones ahora", face = "happy" },
        intro_part2 = { text = "Uno de ellos mata", face = "scared" },
        intro_part3 = { text = "Comenzaremos con alguien al azar", face = "shy" },
        first_player = { text = "El primer jugador es {player}", requiredKeys = {"player"}, face = "shy" },
        next_player = { text = "El siguiente jugador es {player}", requiredKeys = {"player"}, face = "shy" },
        you_eliminated = { text = "Perdiste una vida", face = "dead" },
        player_eliminated = { text = "{player} perdió una vida", requiredKeys = {"player"}, face = "dead" },
        button_safe = { text = "El botón era seguro", face = "happy" },
        press_button = { text = "Presiona el botón", face = "normal" },
    },
}

return Spanish