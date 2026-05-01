--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local Russian: DictTemplate = {
    in_place = {
        ["You"] = { text = "Ты" },
        ["Attack"] = { text = "Атака" },
        ["Defense"] = { text = "Защита" },
        ["Trust"] = { text = "Доверие" },

        ["Yes"] = { text = "Да" },
        ["No"] = { text = "Нет" },

        ["BLUE"] = { text = "СИНИЙ" },
        ["RED"] = { text = "КРАСНЫЙ" },
        ["YELLOW"] = { text = "ЖЕЛТЫЙ" },
        ["GREEN"] = { text = "ЗЕЛЕНЫЙ" },
        ["PINK"] = { text = "РОЗОВЫЙ" },

        ["Blue"] = { text = "Синий" },
        ["Red"] = { text = "Красный" },
        ["Yellow"] = { text = "Желтый" },
        ["Green"] = { text = "Зеленый" },
        ["Pink"] = { text = "Розовый" },

        ["blue"] = { text = "синий" },
        ["red"] = { text = "красный" },
        ["yellow"] = { text = "желтый" },
        ["green"] = { text = "зеленый" },
        ["pink"] = { text = "розовый" },

        ["Vote to Skip"] = { text = "Пропустить (голосовать)" },

        ["Accident Die"] = { text = "Случайная смерть" },
        ["Any button can kill you with chance 4%"] = { text = "Любая кнопка тебя убьет с шансом 4%" },

        ["Alien Language"] = { text = "Инопланетянский" },
        ["I will be talking with you on alien language"] = { text = "Я буду с тобой разговаривать на инопланетянском" },

        ["Mixed Colors"] = { text = "Смешанные цвета" },
        ["Button colors will mix every time now"] = { text = "Цвета всех кнопок будут смешаны" },

        ["No Chat"] = { text = "Без чата" },
        ["Chat will be disabled during rounds"] = { text = "Чат будет выключен во время раундов" },

        ["Random Buttons"] = { text = "Случайные кнопки" },
        ["Buttons will be located on random positions on the map"] = { text = "Положение кнопок будет всегда случайным" },

        ["Random Lives"] = { text = "Случайные жизни" },
        ["Your lives amount will be randomized"] = { text = "Количество ваших жизней будет случайным" },

        ["Simon says... select "] = { text = "Саймон говорит... выбери " },
        ["Simon says... do not select "] = { text = "Саймон говорит... не выбирай " },
        ["Simon says, select "] = { text = "Саймон говорит, выбери " },
        ["Simon says, do not select "] = { text = "Саймон говорит, не выбирай " },

        ["Select "] = { text = "Выбери " },
        ["Do not select "] = { text = "Не выбирай " },

        ["Now... select "] = { text = "Теперь... выбери " },
        ["Now... do not select "] = { text = "Теперь... не выбирай " },
        ["Simply select "] = { text = "Просто выбери " },
        ["My name is Simon, select "] = { text = "Меня зовут Саймон, выбери " },
        ["Simon thinks you should select "] = { text = "Саймон думает, стоит выбрать " },

        ["Simon says... select the color of the sky"] = { text = "Саймон говорит... выбери цвет неба" },
        ["Simon says... select the color of a banana"] = { text = "Саймон говорит... выбери цвет банана" },
        ["Simon says... select the color of a ruby"] = { text = "Саймон говорит... выбери цвет рубина" },
        ["Select the color of the sky"] = { text = "Выбери цвет неба" },
        ["Select the color of a banana"] = { text = "Выбери цвет банана" },
        ["Select the color of a ruby"] = { text = "Выбери цвет рубина" },

        ["Do not change your selection"] = { text = "Не меняй свой выбор" },
        ["Simply not change your selection"] = { text = "Просто не меняй свой выбор" },
        ["Change your selection"] = { text = "Поменяй свой выбор" },
        ["Simon says... change your selection"] = { text = "Саймон говорит... поменяй свой выбор" },
        ["Simon says... do not change your selection"] = { text = "Саймон говорит... не меняй свой выбор" },

        ["You had to select the color"] = { text = "Нужно было выбрать цвет" },
        ["Your selection had to be opposite"] = { text = "Нужно было выбрать наоборот" },

        ["There was no 'Simon says' so you had to do the opposite of 'do not'"] = { text = "Без 'Саймон говорит' нужно делать наоборот от 'не'" },
        ["There was no 'Simon says' so your selection had to be other color"] = { text = "Без 'Саймон говорит' нужно выбрать другой цвет" },
        ["Simply is not 'Simon says', so your selection had to be other color"] = { text = "'Просто' — не 'Саймон говорит', нужен другой цвет" },
        ["His name is Simon, but there was no 'Simon says'"] = { text = "Его зовут Саймон, но нет 'Саймон говорит'" },
        ["Simon thinks but he didn't say 'Simon says'"] = { text = "Саймон думает, но не говорит 'Саймон говорит'" },

        ["The color of the sky is blue"] = { text = "Цвет неба — синий" },
        ["The color of banana is yellow"] = { text = "Цвет банана — желтый" },
        ["The color of ruby is red"] = { text = "Цвет рубина — красный" },
        ["There was no 'Simon says' so your selection had to be NOT blue"] = { text = "Без 'Саймон говорит' выбор должен быть НЕ синим" },
        ["There was no 'Simon says' so your selection had to be NOT yellow"] = { text = "Без 'Саймон говорит' выбор должен быть НЕ желтым" },
        ["There was no 'Simon says' so your selection had to be NOT red"] = { text = "Без 'Саймон говорит' выбор должен быть НЕ красным" },

        ["There was no 'Simon says' so you had to do the opposite of 'simply not'"] = { text = "Без 'Саймон говорит' нужно делать наоборот от 'просто не'" },
        ["There was no 'Simon says' so you had to not click anything"] = { text = "Без 'Саймон говорит' не нужно было ничего нажимать" },
        ["You had to press any button"] = { text = "Нужно было нажать любую кнопку" },
        ["You had to not press any button"] = { text = "Не нужно было нажимать кнопки" },
    },
    --| MISC |--
    misc = {
        error_occurred = { text = "Мы не можем продолжить этот раунд, простите", face = "dead" },
        purchase_not_processed = { text = "Покупка обработана, но сейчас ее нельзя использовать. В следующий раз бесплатно", face = "nerd" },
        purchase_processed = { text = "Ваша покупка обработана!", face = "nerd" },
        players_left = { text = "Осталось {count} испытуемых", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Они отвечают на тайный вопрос...", face = "shy" },
        question_for_you = { text = "У меня к тебе вопрос", face = "normal" },
        question_like_aliens = { text = "Тебе нравятся пришельцы?", face = "alien" },
        oh_no = { text = "О нет...", face = "no_mouth" },
        not_nice = { text = "Это не круто.....", face = "unamused" },
        happy_face = { text = ":D", face = "happy" },
        that_is_cool = { text = "Это круто", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = {
            text = "{p1} и {p2} сыграют в Атака, Защита, Доверие",
            requiredKeys = {"p1", "p2"},
            face = "att_def_tru_icon"
        },
        rules_are_simple = { text = "Правила просты", face = "happy" },
        rules = { text = "Атака бьет Доверие, Защита бьет Атаку, Доверие бьет Защиту", face = "nerd" },
        loser_eliminate = { text = "Проигравший теряет жизнь", face = "dead" },
        choose_your_move = { text = "Выберите свой ход", face = "normal" },
        waiting_for_move = {
            text = "Ждем, пока {p1} и {p2} сделают ход...",
            requiredKeys = {"p1", "p2"},
            face = "normal"
        },
        both_did_not_move = { text = "Оба испытуемых не сделали ход", face = "dead" },
        you_both_chose = { text = "Вы оба выбрали {btn}", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "Они оба выбрали {btn}", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "Ничья, выбирайте снова", face = "shy" },
        tie_they_choose_again = { text = "Ничья, они выберут снова", face = "shy" },

        att_def = { text = "Они отразили вашу атаку", face = "dead" },
        def_att = { text = "Вы отразили их атаку", face = "happy" },

        att_trust = { text = "Они доверились и получили удар", face = "happy" },
        trust_att = { text = "Вас атаковали, пока вы доверяли", face = "dead" },

        def_trust = { text = "Вы поскользнулись, защищаясь от воздуха", face = "dead" },
        trust_def = { text = "Они поскользнулись, защищаясь от воздуха", face = "happy" },

        won_against = { text = "{won} побеждает {lost}!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "У них хитрый тест с кнопкой", face = "click_button_icon" },
        reaction_test = { text = "Читайте и жмите кнопку, если сказано", face = "click_button_icon" },
        not_much_time = { text = "Но на реакцию всего две секунды", face = "no_mouth" },
        be_ready = { text = "Будьте готовы", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },

        button_says_truth = { text = "КНОПКА ГОВОРИТ ПРАВДУ", face = "click_button_icon" },
        button_says_lie = { text = "КНОПКА ГОВОРИТЬ ЛОЖЬ", face = "click_button_icon" },

        you_had_to_click = { text = "Вам следовало нажать", face = "dead" },
        you_had_to_not_click = { text = "Вам не следовало нажимать", face = "dead" },
        you_survived = { text = "Вы выжили", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "Им придется нажать на кнопку первыми", face = "click_button_icon" },
        last_num_eliminate = { text = "Последний нажавший теряет жизнь", face = "dead" },
        click_faster = { text = "Жми быстрее остальных", face = "scared" },
        you_have_to_click = { text = "Готовься нажать кнопку как можно быстрее", face = "click_button_icon" },

        you_did_not_click = { text = "Вы не нажали", face = "angry" },
        you_clicked_too_slow = { text = "Это было медленно", face = "scared" },

        you_survived = { text = "Вы выжили", face = "happy" },
        you_are_eliminated = { text = "Вы потеряли жизнь", face = "dead" },
        wait_for_others = { text = "Жди, пока нажмут остальные", face = "dead" },
        wait_for_green = { text = "Жди, пока кнопка станет зеленой", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Их проверяют, помнят ли они цвет", icon = "color_event_icon" },
        for_dead_start = { text = "Их попросили запомнить цвет", face = "color_event_icon" },
        you_remember_color = { text = "Помнишь цвет, что выбрал ранее?", face = "color_event_icon" },
        lets_check = { text = "Давай проверим твою память", face = "shy" },

        did_not_choose = { text = "Похоже, ты не успел выбрать цвет...", face = "laughing" },
        so_lucky = { text = "Какая удача!", face = "angry" },

        which_one_you_chose = { text = "Помнишь, какой ты выбрал?", face = "nerd" },
        wrong_color = { text = "Ты ошибся.", face = "dead" },
        correct_color = { text = "Умник, ты помнишь!", face = "happy" },
        good_job = { text = "Хорошая работа", face = "shy" },

        about_to_show_colors = { text = "Я покажу тебе 3 цвета", face = "color_event_icon" },
        remember_color = { text = "Выбери цвет и запомни его", face = "normal" },
        choose = { text = "Выбирай", face = "nerd" },

        red = { text = "Очень интересно", face = "happy" },
        blue = { text = "Цвет неба, понятно", face = "happy" },
        pink = { text = "Зачем? Хотя выглядит вкусно", face = "happy" },
        yellow = { text = "Любишь бананы?", face = "happy" },
        green = { text = "Цвет природы, хороший выбор", face = "happy" },
        nothing = { text = "Ничего? Тогда пусть будет {color}", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Они сейчас повторят комбинацию", face = "combo_event_icon" },
        repeat_after_me = { text = "Теперь тебе нужно повторить за мной", face = "combo_event_icon" },
        players_to_eliminate = { text = "Испытуемые с большим числом ошибок теряют жизнь", face = "dead" },
        lets_start = { text = "Начнем", face = "shy" },
        my_turn = { text = "Моя очередь, смотри внимательно", face = "normal" },
        your_turn = { text = "Твоя очередь", face = "nerd" },
        clicks_left = { text = "Осталось {num} нажатий", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Подождем, пока остальные закончат", face = "normal" },
        mistakes_count = { text = "У тебя {num} ошибок...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Посмотрим, что тут у нас", face = "scared" },

        you_eliminated = { text = "Ты один из тех, кто теряет жизнь", face = "dead" },
        you_survived = { text = "Ты выжил", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "{p1} и {p2} сыграют в смертельную дуэль", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "Самый быстрый испытуемый выживает", face = "normal" },
        you_did_not_click = { text = "Ты не нажал", face = "angry" },
        you_are_eliminated = { text = "Ты потерял жизнь", face = "dead" },
        good_job = { text = "Отличная работа", face = "shy" },
        you_were_fast_enough = { text = "Похоже, теперь ты умрешь", face = "happy" },  -- Changed both to make fun of them
        you_are_slow = { text = "О, это было быстро!", face = "laughing" },
        won = { text = "{player} выиграл эту дуэль", face = "happy", requiredKeys = {"player"} },
        wait_for_green = { text = "Жди, пока кнопка станет зеленой", face = { text = "..." } }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "Они решат, нажимать кнопку или нет", face = "even_odd_event_icon" },
        intro_alive = { text = "Тебе решать, нажимать кнопку или нет", face = "even_odd_event_icon" },
        intro_counting = { text = "Затем я посчитаю нажатия", face = "nerd" },
        intro_odd = { text = "Если нечетное, все нажавшие выбывают", face = "even_odd_event_icon" },
        intro_even = { text = "Если четное, ненажавшие выбывают", face = "even_odd_event_icon" },

        remember_to_talk = { text = "Не забудьте поговорить с остальными", face = "shy" },

        time_to_count = { text = "Время считать", face = "scared" },
        player_clicked = { text = "{player} нажал", requiredKeys = {"player"}, face = "normal" },

        count_even = { text = "Четное", face = "normal" },
        count_odd = { text = "Нечетное", face = "normal" },

        you_survived = { text = "Ты выжил", face = "happy" },
        you_are_eliminated = { text = "Ты потерял жизнь", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "Появилось 100 кнопок", face = "laughing" },
        intro_ready = { text = "Будьте готовы искать", face = "happy" },
        intro_100_buttons = { text = "100 кнопок упадут с неба", face = "scared" },
        intro_first_rewarded = { text = "Одна кнопка дает кое-что крутое", face = "shy" },
        good_luck = { text = "Удачи в поисках", face = "laughing" },
        you_found_god_btn = { text = "Ты нашел кнопку!", face = "happy" },
        someone_found_god_btn = { text = "{player} нашел кнопку", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Никто не нашел кнопку, ха-ха-ха", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Кто-то получит подарок", face = "laughing" },
        intro_alive_part1 = { text = "Один испытуемый сейчас получит подарок", face = "happy" },
        intro_alive_part2 = { text = "И это будет......", face = "scared" },
        dead_who_got = { text = "{player} получил подарок", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "Ты!", face = "happy" },
        you_got_tool_part2 = { text = "Тут есть серая кнопка, нажми ее", face = "shy" },
        you_got_tool_part3 = { text = "А затем кликни на того, кто тебе нравится", face = "no_mouth" },
        you_got_tool_part4 = { text = "Появится очень красивое конфетти", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "Он теперь рад своему подарку", face = "happy" },
        someone_got_tool_part3 = { text = "Это очень круто", face = "shy" },
        someone_got_tool_part4 = { text = "Разозли их", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Сейчас я свяжу двух людей вместе", face = "scared" },
        intro_part2 = { text = "Если один умрет, второй тоже", face = "dead" },
        intro_part3 = { text = "Надеюсь, это будешь ты, ха-ха", face = "normal" },
        first_player_is = { text = "Первый испытуемый...", face = "normal" },
        second_player_is = { text = "Второй испытуемый...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "{player} сейчас решит пример", requiredKeys = {"player"}, face = "nerd" },

        intro_self_q1 = { text = "Думаешь, ты умный?", face = "nerd" },
        intro_self_q2 = { text = "Кто-то умрет, если думает иначе", face = "scared" },

        intro_others_q1 = { text = "Думаешь, {player} хорош в математике?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Придется это выяснить", face = "shy" },

        calculate_this = { text = "Реши это сейчас:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },

        is_player_smart = { text = "{player} достаточно умен, чтобы решить:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },

        you_answer_right = { text = "Твой ответ был верным", face = "happy" },
        you_answer_wrong = { text = "Твой ответ был неверным", face = "scared" },

        you_not_believed = { text = "Но в тебя никто даже не верил...", face = "dead" },
        you_had_to_answer = { text = "Тебе нужно было ответить...", face = "dead" },
        you_wrong_lucky = { text = "Ты ошибся, но на этот раз повезло", face = "happy" },
        you_wrong = { text = "Ты ошибся", face = "dead" },
        you_right = { text = "Ты был прав", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "Только что появился лабиринт", face = "normal" },
        intro_part2 = { text = "Там ровно 6 кнопок", face = "normal" },
        intro_part3 = { text = "Одна опасна, другая полезна", face = "scared" },
        intro_part4 = { text = "Удачи в поисках", face = "happy" },
        somebody_awarded = { text = "Кого-то наградили", face = "happy" },
        no_one_awarded = { text = "Никто не был награжден", face = "no_mouth" },
    },

    --| OBBY EVENT |--
    obby = {
        intro_part1 = { text = "Я создал очень легкое испытание", face = "normal" },
        intro_part2 = { text = "В конце есть одна кнопка", face = "normal" },
        intro_part3 = { text = "Нажми первым, чтобы получить вещь", face = "scared" },
        intro_part4 = { text = "Последний нажавший получит кошмар", face = "happy" },
        intro_part5 = { text = "Не трать тут свое время зря", face = "dead" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Кто-то случайный сейчас оживет", face = "shy" },
        player_revived = { text = "И это {player}", requiredKeys = {"player"}, face = "happy" },

        intro_vote_common = { text = "Хотите, чтобы кто-то вернулся?", face = "shy" },
        intro_vote_candidate = { text = "Испытуемые решат, будешь ли это ты", face = "shy" },
        intro_dead_not_you = { text = "Кто-то, но точно не ты, вернется", face = "no_mouth" },
        intro_choose_wise = { text = "Даже если нет, тебе нужно выбрать", face = "nerd" },

        you_are_revived = { text = "Поздоровайся со всеми!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = {
            text = "Им придется пожертвовать собой ради {p1} и {p2}",
            requiredKeys = {"p1", "p2"},
            face = "scared"
        },

        chosen_you_1 = { text = "Твоя жизнь может оборваться сейчас", face = "scared" },
        chosen_you_2 = { text = "Кто-то должен пожертвовать собой ради тебя", face = "scared" },

        chosen_others_1 = { text = "{p1} и {p2} были выбраны.", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "Пожертвуешь собой ради их спасения?", face = "shy" },

        press_to_save = { text = "Нажми, чтобы спасти их", face = "shy" },
        choice_cannot_be_undone = { text = "Твой выбор нельзя отменить", face = "dead" },

        you_are_eliminated = { text = "Ты потерял жизнь", face = "dead" },
        they_are_eliminated = { text = "Попрощайся с ними", face = "scared" },

        you_are_saved = { text = "Как жаль, ты жив...", face = "angry" },
        you_saved_them = { text = "Ты такой хороший человек", face = "dead" },
        they_were_saved = { text = "{p1} и {p2} теперь в порядке", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "Они сейчас слушают Саймона", face = "nerd" },
        intro_alive_1 = { text = "Я теперь Саймон, четко выполняй команды", face = "shy" },
        intro_alive_2 = { text = "Делай наоборот, если я не сказал 'Саймон говорит'", face = "nerd" },
        intro_alive_3 = { text = "На слове 'выбери', жми кнопку, чтобы она загорелась", face = "nerd" },
        intro_alive_4 = { text = "Начнем с чего-нибудь простого", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Будь другом для {p2}, вам нужно будет разделить или украсть", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} и {p2} должны разделить или украсть", requiredKeys = {"p1","p2"}, face = "happy" },

        rule_both_split = { text = "Оба делят — ничего не происходит", face = "happy" },
        rule_one_steal = { text = "Один крадет — другой умирает", face = "scared" },
        rule_both_steal = { text = "Оба крадут — вы оба умираете", face = "laughing" },
        rule_both_steal_others = { text = "Оба крадут — они оба умирают", face = "laughing" },

        choose_wisely = { text = "Выбирайте с умом", face = "nerd" },
        waiting_for_players = { text = "Ждем решения испытуемых", face = "normal" },

        both_steal = { text = "Оба испытуемых выбрали украсть, они оба умирают", face = "laughing" },
        stealer_chosen = { text = "{stealer} украл, {victim} теряет жизнь", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Оба испытуемых выбрали разделить, они выживают", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "Твоя кнопка плохая", face = "shy" },
        intro_killer_2 = { text = "Каждый, кто ее нажмет, умрет", face = "scared" },
        intro_killer_3 = { text = "Убеди других нажать ее за тебя (твоя плохая)", face = "normal" },

        intro_saver_1 = { text = "Твоя кнопка абсолютно нормальная", face = "shy" },
        intro_saver_2 = { text = "Каждый, кто ее нажмет, не умрет", face = "happy" },
        intro_saver_3 = { text = "Убеди других нажать ее за тебя (твоя хорошая)", face = "normal" },

        intro_others_1 = { text = "Вам нужно поговорить с {p1} и {p2}", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "У одного из них кнопка, которая убьет вас", face = "normal" },
        intro_others_3 = { text = "И кому же вы поверите?", face = "nerd" },

        lets_see = { text = "Посмотрим, кто умер...", face = "normal" },

        result_no_choice = { text = "Вы не выбрали кнопку, вы умерли", face = "dead" },
        result_chose_died = { text = "Вы выбрали кнопку {p}, вы умерли", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "Вы выбрали кнопку {p}, вы в безопасности", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "Они голосуют, кого исключить", face = "shy" },

        intro_common_1 = { text = "Время голосовать на выбывание", face = "normal" },
        intro_candidate_fate = { text = "Другие решат твою судьбу.", face = "scared" },
        intro_choose_wise = { text = "Выбери того, кто тебе не нравится", face = "happy" },

        candidate_line_1 = { text = "Итак, я вижу, они голосуют", face = "normal" },
        candidate_line_2 = { text = "Набравший больше всех голосов выбывает", face = "shy" },
        candidate_line_3 = { text = "Как думаешь, ты им нравишься?", face = "normal" },
        candidate_line_4 = { text = "Представь, если нет", face = "scared" },
        candidate_line_5 = { text = "Ты проиграешь эту игру, ха-ха", face = "normal" },
        candidate_line_6 = { text = "А проиграть эксперимент — это так плохо", face = "shy" },
        candidate_line_7 = { text = "Так что надеюсь, это ты", face = "scared" },

        you_eliminated = { text = "Вы потеряли жизнь... мне жаль", face = "dead" },
        player_eliminated = { text = "{player} потерял жизнь", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Привет, {player}", requiredKeys = {"player"}, face = "happy" },
        intro_button_experiment = { text = "Добро пожаловать в Эксперимент с Кнопкой", face = "normal" },
        intro_tested = { text = "Мы вас проверим.", face = "scared" },
        intro_easy_hard = { text = "Не думайте, что будет легко", face = "dead" },
        intro_begin = { text = "Давайте начнем", face = "happy" },
        intro_special = { text = "У нас теперь особые раунды", face = "alien" },
        intro_special2 = { text = "Сейчас появятся три разных эффекта", face = "alien" },
        special_text = { text = "{text}", face = "scared", requiredKeys = {"text"} },
        special_text2 = { text = "{text}", face = "nerd", requiredKeys = {"text"} },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "{survivor} дошел до конца", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Отличное выступление!", face = "shy" },
        survivor_congratulations = { text = "Тут есть кнопка, можешь нажать ее", face = "happy" },
    },

    --| FIVE BUTTONS EVENT |--
    five_buttons = {
        intro_part1 = { text = "Сейчас появятся пять кнопок", face = "happy" },
        intro_part2 = { text = "Одна из них убивает", face = "scared" },
        intro_part3 = { text = "Мы начнем с кого-то случайного", face = "shy" },
        first_player = { text = "Первый игрок — {player}", requiredKeys = {"player"}, face = "shy" },
        next_player = { text = "Следующий игрок — {player}", requiredKeys = {"player"}, face = "shy" },
        you_eliminated = { text = "Вы потеряли жизнь", face = "dead" },
        player_eliminated = { text = "{player} потерял жизнь", requiredKeys = {"player"}, face = "dead" },
        button_safe = { text = "Кнопка была безопасной", face = "happy" },
        press_button = { text = "Нажми кнопку", face = "normal" },
    },
}

return Russian