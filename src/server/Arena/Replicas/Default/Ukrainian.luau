--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local Ukrainian: DictTemplate = {
    in_place = {
        ["You"] = { text = "Ви" },
        ["Attack"] = { text = "Атака" },
        ["Defense"] = { text = "Захист" },
        ["Trust"] = { text = "Довіра" },

        ["Yes"] = { text = "Так" },
        ["No"] = { text = "Ні" },

        ["BLUE"] = { text = "СИНІЙ" },
        ["RED"] = { text = "ЧЕРВОНИЙ" },
        ["YELLOW"] = { text = "ЖОВТИЙ" },
        ["GREEN"] = { text = "ЗЕЛЕНИЙ" },
        ["PINK"] = { text = "РОЖЕВИЙ" },

        ["Blue"] = { text = "Синій" },
        ["Red"] = { text = "Червоний" },
        ["Yellow"] = { text = "Жовтий" },
        ["Green"] = { text = "Зелений" },
        ["Pink"] = { text = "Рожевий" },

        ["blue"] = { text = "синій" },
        ["red"] = { text = "червоний" },
        ["yellow"] = { text = "жовтий" },
        ["green"] = { text = "зелений" },
        ["pink"] = { text = "рожевий" },

        ["Vote to Skip"] = { text = "Проголосувати за пропуск" },

        ["Accident Die"] = { text = "Випадкова смерть" },
        ["Any button can kill you with chance 4%"] = { text = "Будь-яка кнопка може вбити тебе з шансом 4%" },

        ["Alien Language"] = { text = "Інопланетна мова" },
        ["I will be talking with you on alien language"] = { text = "Я розмовлятиму з тобою інопланетною мовою" },

        ["Mixed Colors"] = { text = "Змішані кольори" },
        ["Button colors will mix every time now"] = { text = "Кольори кнопок тепер будуть змішуватися щоразу" },

        ["No Chat"] = { text = "Без чату" },
        ["Chat will be disabled during rounds"] = { text = "Чат буде вимкнено під час раундів" },

        ["Random Buttons"] = { text = "Випадкові кнопки" },
        ["Buttons will be located on random positions on the map"] = { text = "Кнопки будуть розташовані у випадкових місцях" },

        ["Random Lives"] = { text = "Випадкові життя" },
        ["Your lives amount will be randomized"] = { text = "Кількість твоїх життів буде випадковою" },

        ["Simon says... select "] = { text = "Саймон каже... обери " },
        ["Simon says... do not select "] = { text = "Саймон каже... не обирай " },
        ["Simon says, select "] = { text = "Саймон каже, обери " },
        ["Simon says, do not select "] = { text = "Саймон каже, не обирай " },

        ["Select "] = { text = "Обери " },
        ["Do not select "] = { text = "Не обирай " },

        ["Now... select "] = { text = "Тепер... обери " },
        ["Now... do not select "] = { text = "Тепер... не обирай " },
        ["Simply select "] = { text = "Просто обери " },
        ["My name is Simon, select "] = { text = "Мене звати Саймон, обери " },
        ["Simon thinks you should select "] = { text = "Саймон думає, варто обрати " },

        ["Simon says... select the color of the sky"] = { text = "Саймон каже... обери колір неба" },
        ["Simon says... select the color of a banana"] = { text = "Саймон каже... обери колір банана" },
        ["Simon says... select the color of a ruby"] = { text = "Саймон каже... обери колір рубіна" },
        ["Select the color of the sky"] = { text = "Обери колір неба" },
        ["Select the color of a banana"] = { text = "Обери колір банана" },
        ["Select the color of a ruby"] = { text = "Обери колір рубіна" },

        ["Do not change your selection"] = { text = "Не змінюй свій вибір" },
        ["Simply not change your selection"] = { text = "Просто не змінюй свій вибір" },
        ["Change your selection"] = { text = "Зміни свій вибір" },
        ["Simon says... change your selection"] = { text = "Саймон каже... зміни свій вибір" },
        ["Simon says... do not change your selection"] = { text = "Саймон каже... не змінюй свій вибір" },

        ["You had to select the color"] = { text = "Треба було обрати колір" },
        ["Your selection had to be opposite"] = { text = "Твій вибір мав бути протилежним" },

        ["There was no 'Simon says' so you had to do the opposite of 'do not'"] = { text = "Без 'Саймон каже' треба робити навпаки від 'не'" },
        ["There was no 'Simon says' so your selection had to be other color"] = { text = "Без 'Саймон каже' треба було обрати інший колір" },
        ["Simply is not 'Simon says', so your selection had to be other color"] = { text = "'Просто' — не 'Саймон каже', потрібен інший колір" },
        ["His name is Simon, but there was no 'Simon says'"] = { text = "Його звати Саймон, але немає 'Саймон каже'" },
        ["Simon thinks but he didn't say 'Simon says'"] = { text = "Саймон думає, але не каже 'Саймон каже'" },

        ["The color of the sky is blue"] = { text = "Колір неба — синій" },
        ["The color of banana is yellow"] = { text = "Колір банана — жовтий" },
        ["The color of ruby is red"] = { text = "Колір рубіна — червоний" },
        ["There was no 'Simon says' so your selection had to be NOT blue"] = { text = "Без 'Саймон каже' вибір мав бути НЕ синім" },
        ["There was no 'Simon says' so your selection had to be NOT yellow"] = { text = "Без 'Саймон каже' вибір мав бути НЕ жовтим" },
        ["There was no 'Simon says' so your selection had to be NOT red"] = { text = "Без 'Саймон каже' вибір мав бути НЕ червоним" },

        ["There was no 'Simon says' so you had to do the opposite of 'simply not'"] = { text = "Без 'Саймон каже' треба робити навпаки від 'просто не'" },
        ["There was no 'Simon says' so you had to not click anything"] = { text = "Без 'Саймон каже' не треба було нічого натискати" },
        ["You had to press any button"] = { text = "Треба було натиснути будь-яку кнопку" },
        ["You had to not press any button"] = { text = "Не треба було натискати кнопки" },

        ["Press button to move"] = { text = "Натисніть кнопку, щоб зробити хід" },
        ["Wait for them to move"] = { text = "Зачекайте, поки вони зроблять хід" },
        ["Remember combination"] = { text = "Запам’ятайте комбінацію" },
        ["Repeat combination (do your best)"] = { text = "Повторіть комбінацію (як зможете)" },
        ["Click as fast as possible on green"] = { text = "Натискайте на зелене якомога швидше" },
        ["One button kills"] = { text = "Одна кнопка вбиває" },
        ["One button rewards"] = { text = "Одна кнопка дає нагороду" },
        ["Equip and press on other player to kill"] = { text = "Візьміть предмет і натисніть на іншого гравця, щоб убити" },
        ["When 4 subjects are left, you get unlinked"] = { text = "Коли залишається 4 гравці, ви більше не пов’язані" },
        ["You lose life if you answer is wrong"] = { text = "Ви втрачаєте життя, якщо відповідь неправильна" },
        ["Simon will try to trick you"] = { text = "Саймон спробує вас обманути" },
        ["People vote for who to eliminate"] = { text = "Гравці голосують, кого виключити" },
        ["One button kills, one button rewards"] = { text = "Одна кнопка вбиває, інша дає нагороду" },
        ["Like the game if you enjoy playing!"] = { text = "Лайкни гру якщо подобається грати!" }
    },
    --| MISC |--
    misc = {
        error_occurred = { text = "Сталася помилка, ми не можемо продовжити", face = "dead" },
        purchase_not_processed = { text = "Покупка оброблена, але зараз її не можна використати. Наступного разу безкоштовно", face = "nerd" },
        purchase_processed = { text = "Вашу покупку оброблено!", face = "nerd" },
        players_left = { text = "Залишилось {count} піддослідних", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Вони відповідають на таємне питання...", face = "shy" },
        question_for_you = { text = "Маю до тебе питання", face = "normal" },
        question_like_aliens = { text = "Тобі подобаються прибульці?", face = "alien" },
        oh_no = { text = "О ні...", face = "no_mouth" },
        not_nice = { text = "Це не дуже круто.....", face = "unamused" },
        happy_face = { text = ":D", face = "happy" },
        that_is_cool = { text = "Це круто", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = {
            text = "{p1} та {p2} зіграють в Атака, Захист, Довіра",
            requiredKeys = {"p1", "p2"},
            face = "att_def_tru_icon"
        },
        rules_are_simple = { text = "Правила прості", face = "happy" },
        rules = { text = "Атака б'є Довіру, Захист б'є Атаку, Довіра б'є Захист", face = "nerd" },
        loser_eliminate = { text = "Той, хто програє, втрачає життя", face = "dead" },
        choose_your_move = { text = "Обирайте свій хід", face = "normal" },
        waiting_for_move = {
            text = "Чекаємо, поки {p1} та {p2} зроблять хід...",
            requiredKeys = {"p1", "p2"},
            face = "normal"
        },
        both_did_not_move = { text = "Обидва піддослідних не зробили хід", face = "dead" },
        you_both_chose = { text = "Ви обидва обрали {btn}", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "Вони обидва обрали {btn}", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "Нічия, обирайте знову", face = "shy" },
        tie_they_choose_again = { text = "Нічия, вони оберуть знову", face = "shy" },

        att_def = { text = "Вони відбили вашу атаку", face = "dead" },
        def_att = { text = "Ви відбили їхню атаку", face = "happy" },

        att_trust = { text = "Вони довірились і отримали удар", face = "happy" },
        trust_att = { text = "Вас атакували, поки ви довіряли", face = "dead" },

        def_trust = { text = "Ви посковзнулися, захищаючись від повітря", face = "dead" },
        trust_def = { text = "Вони посковзнулися, захищаючись від повітря", face = "happy" },

        won_against = { text = "{won} перемагає {lost}!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "У них хитрий тест із кнопкою", face = "click_button_icon" },
        reaction_test = { text = "Читайте і тисніть кнопку, якщо так написано", face = "click_button_icon" },
        not_much_time = { text = "Але на реакцію всього дві секунди", face = "no_mouth" },
        be_ready = { text = "Будьте готові", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },

        button_says_truth = { text = "КНОПКА КАЖЕ ПРАВДУ", face = "click_button_icon" },
        button_says_lie = { text = "КНОПКА КАЖЕ БРЕХНЮ", face = "click_button_icon" },

        you_had_to_click = { text = "Вам варто було натиснути", face = "dead" },
        you_had_to_not_click = { text = "Вам не варто було натискати", face = "dead" },
        you_survived = { text = "Ви вижили", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "Їм доведеться натиснути кнопку першими", face = "click_button_icon" },
        last_num_eliminate = { text = "Останній, хто натисне, втрачає життя", face = "dead" },
        click_faster = { text = "Тисни швидше за інших", face = "scared" },
        you_have_to_click = { text = "Готуйся натиснути кнопку якнайшвидше", face = "click_button_icon" },

        you_did_not_click = { text = "Ви не натиснули", face = "angry" },
        you_clicked_too_slow = { text = "Це було повільно", face = "scared" },

        you_survived = { text = "Ви вижили", face = "happy" },
        you_are_eliminated = { text = "Ви втратили життя", face = "dead" },
        wait_for_others = { text = "Чекай, поки натиснуть інші", face = "dead" },
        wait_for_green = { text = "Чекай, поки кнопка стане зеленою", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Їх перевіряють, чи пам'ятають вони колір", icon = "color_event_icon" },
        for_dead_start = { text = "Їх попросили запам'ятати колір", face = "color_event_icon" },
        you_remember_color = { text = "Пам'ятаєш колір, який обрав раніше?", face = "color_event_icon" },
        lets_check = { text = "Давай перевіримо твою пам'ять", face = "shy" },

        did_not_choose = { text = "Схоже, ти не встиг обрати колір...", face = "laughing" },
        so_lucky = { text = "Яка вдача!", face = "angry" },

        which_one_you_chose = { text = "Пам'ятаєш, який ти обрав?", face = "nerd" },
        wrong_color = { text = "Ти помилився.", face = "dead" },
        correct_color = { text = "Розумник, ти пам'ятаєш!", face = "happy" },
        good_job = { text = "Гарна робота", face = "shy" },

        about_to_show_colors = { text = "Я покажу тобі 3 кольори", face = "color_event_icon" },
        remember_color = { text = "Обери колір та запам'ятай його", face = "normal" },
        choose = { text = "Обирай", face = "nerd" },

        red = { text = "Дуже цікаво", face = "happy" },
        blue = { text = "Колір неба, зрозуміло", face = "happy" },
        pink = { text = "Навіщо? Хоча виглядає смачно", face = "happy" },
        yellow = { text = "Любиш банани?", face = "happy" },
        green = { text = "Колір природи, гарний вибір", face = "happy" },
        nothing = { text = "Нічого? Тоді нехай буде {color}", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Зараз вони повторять комбінацію", face = "combo_event_icon" },
        repeat_after_me = { text = "Тепер тобі треба повторити за мною", face = "combo_event_icon" },
        players_to_eliminate = { text = "Піддослідні з найбільшою кількістю помилок втрачають життя", face = "dead" },
        lets_start = { text = "Почнемо", face = "shy" },
        my_turn = { text = "Моя черга, дивись уважно", face = "normal" },
        your_turn = { text = "Твоя черга", face = "nerd" },
        clicks_left = { text = "Залишилось {num} натискань", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Почекаємо, поки інші закінчать", face = "normal" },
        mistakes_count = { text = "У тебе {num} помилок...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Подивимось, що тут у нас", face = "scared" },

        you_eliminated = { text = "Ти один із тих, хто втрачає життя", face = "dead" },
        you_survived = { text = "Ти вижив", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "{p1} та {p2} зіграють у смертельну дуель", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "Найшвидший піддослідний виживає", face = "normal" },
        you_did_not_click = { text = "Ти не натиснув", face = "angry" },
        you_are_eliminated = { text = "Ти втратив життяив життя", face = "dead" },
        good_job = { text = "Відмінна робота", face = "shy" },
        you_were_fast_enough = { text = "Схоже, тепер ти помреш", face = "happy" },  -- Changed both to make fun of them
        you_are_slow = { text = "О, це було швидко!", face = "laughing" },
        won = { text = "{player} виграв цю дуель", face = "happy", requiredKeys = {"player"} },
        wait_for_green = { text = "Чекай, поки кнопка стане зеленою", face = { text = "..." } }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "Вони вирішать, натискати кнопку чи ні", face = "even_odd_event_icon" },
        intro_alive = { text = "Тобі вирішувати, натискати кнопку чи ні", face = "even_odd_event_icon" },
        intro_counting = { text = "Потім я порахую натискання", face = "nerd" },
        intro_odd = { text = "Якщо непарне, всі, хто натиснув, вибувають", face = "even_odd_event_icon" },
        intro_even = { text = "Якщо парне, ті, хто не натиснув, вибувають", face = "even_odd_event_icon" },

        remember_to_talk = { text = "Не забудьте поговорити з іншими", face = "shy" },

        time_to_count = { text = "Час рахувати", face = "scared" },
        player_clicked = { text = "{player} натиснув", requiredKeys = {"player"}, face = "normal" },

        count_even = { text = "Парне", face = "normal" },
        count_odd = { text = "Непарне", face = "normal" },

        you_survived = { text = "Ти вижив", face = "happy" },
        you_are_eliminated = { text = "Ти вибув", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "З'явилося 100 кнопок", face = "laughing" },
        intro_ready = { text = "Будьте готові шукати", face = "happy" },
        intro_100_buttons = { text = "100 кнопок впадуть із неба", face = "scared" },
        intro_first_rewarded = { text = "Одна кнопка дає дещо круте", face = "shy" },
        good_luck = { text = "Щасти в пошуках", face = "laughing" },
        you_found_god_btn = { text = "Ти знайшов кнопку!", face = "happy" },
        someone_found_god_btn = { text = "{player} знайшов кнопку", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Ніхто не знайшов кнопку, ха-ха-ха", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Хтось отримає подарунок", face = "laughing" },
        intro_alive_part1 = { text = "Один піддослідний зараз отримає подарунок", face = "happy" },
        intro_alive_part2 = { text = "І це буде......", face = "scared" },
        dead_who_got = { text = "{player} отримав подарунок", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "Ти!", face = "happy" },
        you_got_tool_part2 = { text = "Тут є сіра кнопка, натисни її", face = "shy" },
        you_got_tool_part3 = { text = "А потім клікни на того, хто тобі подобається", face = "no_mouth" },
        you_got_tool_part4 = { text = "З'явиться дуже гарне конфетті", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "Тепер він радий своєму подарунку", face = "happy" },
        someone_got_tool_part3 = { text = "Це дуже круто", face = "shy" },
        someone_got_tool_part4 = { text = "Розлюти їх", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Зараз я зв'яжу двох людей разом", face = "scared" },
        intro_part2 = { text = "Якщо один помре, інший також", face = "dead" },
        intro_part3 = { text = "Сподіваюсь, це будеш ти, ха-ха", face = "normal" },
        first_player_is = { text = "Перший піддослідний...", face = "normal" },
        second_player_is = { text = "Другий піддослідний...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "{player} зараз розв'яже приклад", requiredKeys = {"player"}, face = "nerd" },

        intro_self_q1 = { text = "Думаєш, ти розумний?", face = "nerd" },
        intro_self_q2 = { text = "Хтось помре, якщо думає інакше", face = "scared" },

        intro_others_q1 = { text = "Думаєш, {player} добре знає математику?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Доведеться це з'ясувати", face = "shy" },

        calculate_this = { text = "Розв'яжи це зараз:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },

        is_player_smart = { text = "{player} достатньо розумний, щоб розв'язати:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },

        you_answer_right = { text = "Твоя відповідь була правильною", face = "happy" },
        you_answer_wrong = { text = "Твоя відповідь була неправильною", face = "scared" },

        you_not_believed = { text = "Але в тебе ніхто навіть не вірив...", face = "dead" },
        you_had_to_answer = { text = "Тобі потрібно було відповісти...", face = "dead" },
        you_wrong_lucky = { text = "Ти помилився, але цього разу пощастило", face = "happy" },
        you_wrong = { text = "Ти помилився", face = "dead" },
        you_right = { text = "Ти мав рацію", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "Щойно з'явився лабіринт", face = "normal" },
        intro_part2 = { text = "Там рівно 6 кнопок", face = "normal" },
        intro_part3 = { text = "Одна небезпечна, інша корисна", face = "scared" },
        intro_part4 = { text = "Щасти в пошуках", face = "happy" },
        somebody_awarded = { text = "Когось нагородили", face = "happy" },
        no_one_awarded = { text = "Ніхто не отримав нагороду", face = "no_mouth" },
    },

    --| OBBY EVENT |--
    obby = {
        intro_part1 = { text = "Я створив дуже легке випробування", face = "normal" },
        intro_part2 = { text = "В кінці є одна кнопка", face = "normal" },
        intro_part3 = { text = "Натисни першим, щоб отримати річ", face = "scared" },
        intro_part4 = { text = "Той, хто натисне останнім, отримає жах", face = "happy" },
        intro_part5 = { text = "Не витрачай тут свій час даремно", face = "dead" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Хтось випадковий зараз оживе", face = "shy" },
        player_revived = { text = "І це {player}", requiredKeys = {"player"}, face = "happy" },

        intro_vote_common = { text = "Хочете, щоб хтось повернувся?", face = "shy" },
        intro_vote_candidate = { text = "Піддослідні вирішать, чи будеш це ти", face = "shy" },
        intro_dead_not_you = { text = "Хтось, але точно не ти, повернеться", face = "no_mouth" },
        intro_choose_wise = { text = "Навіть якщо ні, тобі треба обрати", face = "nerd" },

        you_are_revived = { text = "Привітайся з усіма!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = {
            text = "Їм доведеться пожертвувати собою заради {p1} та {p2}",
            requiredKeys = {"p1", "p2"},
            face = "scared"
        },

        chosen_you_1 = { text = "Твоє життя може обірватися зараз", face = "scared" },
        chosen_you_2 = { text = "Хтось має пожертвувати собою заради тебе", face = "scared" },

        chosen_others_1 = { text = "{p1} та {p2} були обрані.", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "Пожертвуєш собою заради їхнього порятунку?", face = "shy" },

        press_to_save = { text = "Натисни, щоб врятувати їх", face = "shy" },
        choice_cannot_be_undone = { text = "Твій вибір не можна скасувати", face = "dead" },

        you_are_eliminated = { text = "Ти втратив життя", face = "dead" },
        they_are_eliminated = { text = "Попрощайся з ними", face = "scared" },

        you_are_saved = { text = "Як шкода, ти живий...", face = "angry" },
        you_saved_them = { text = "Ти така хороша людина", face = "dead" },
        they_were_saved = { text = "{p1} та {p2} тепер в порядку", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "Вони зараз слухають Саймона", face = "nerd" },
        intro_alive_1 = { text = "Я тепер Саймон, чітко виконуй команди", face = "shy" },
        intro_alive_2 = { text = "Роби навпаки, якщо я не сказав 'Саймон каже'", face = "nerd" },
        intro_alive_3 = { text = "На слові 'обери', тисни кнопку, щоб вона засвітилася", face = "nerd" },
        intro_alive_4 = { text = "Почнемо з чогось простого", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Будь другом для {p2}, вам доведеться поділити або вкрасти", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} та {p2} мають поділити або вкрасти", requiredKeys = {"p1","p2"}, face = "happy" },

        rule_both_split = { text = "Обидва ділять — нічого не відбувається", face = "happy" },
        rule_one_steal = { text = "Один краде — інший помирає", face = "scared" },
        rule_both_steal = { text = "Обидва крадуть — ви обидва помираєте", face = "laughing" },
        rule_both_steal_others = { text = "Обидва крадуть — вони обидва помирають", face = "laughing" },

        choose_wisely = { text = "Обирайте з розумом", face = "nerd" },
        waiting_for_players = { text = "Чекаємо на рішення піддослідних", face = "normal" },

        both_steal = { text = "Обидва піддослідних обрали вкрасти, вони помирають", face = "laughing" },
        stealer_chosen = { text = "{stealer} вкрав, {victim} втрачає життя", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Обидва піддослідних обрали поділити, вони виживають", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "Твоя кнопка погана", face = "shy" },
        intro_killer_2 = { text = "Кожен, хто її натисне, помре", face = "scared" },
        intro_killer_3 = { text = "Переконай інших натиснути її за тебе (твоя погана)", face = "normal" },

        intro_saver_1 = { text = "Твоя кнопка абсолютно нормальна", face = "shy" },
        intro_saver_2 = { text = "Кожен, хто її натисне, не помре", face = "happy" },
        intro_saver_3 = { text = "Переконай інших натиснути її за тебе (твоя хороша)", face = "normal" },

        intro_others_1 = { text = "Вам треба поговорити з {p1} та {p2}", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "В одного з них кнопка, яка вб'є вас", face = "normal" },
        intro_others_3 = { text = "І кому ж ви повірите?", face = "nerd" },

        lets_see = { text = "Подивимось, хто помер...", face = "normal" },

        result_no_choice = { text = "Ви не обрали кнопку, ви померли", face = "dead" },
        result_chose_died = { text = "Ви обрали кнопку {p}, ви померли", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "Ви обрали кнопку {p}, ви в безпеці", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "Вони голосують, кого виключити", face = "shy" },

        intro_common_1 = { text = "Час голосувати на вибування", face = "normal" },
        intro_candidate_fate = { text = "Інші вирішать твою долю.", face = "scared" },
        intro_choose_wise = { text = "Обери того, хто тобі не подобається", face = "happy" },

        candidate_line_1 = { text = "Отже, я бачу, вони голосують", face = "normal" },
        candidate_line_2 = { text = "Той, хто набере найбільше голосів, вибуває", face = "shy" },
        candidate_line_3 = { text = "Як думаєш, ти їм подобаєшся?", face = "normal" },
        candidate_line_4 = { text = "Уяви, якщо ні", face = "scared" },
        candidate_line_5 = { text = "Ти програєш цю гру, ха-ха", face = "normal" },
        candidate_line_6 = { text = "А програти експеримент — це так погано", face = "shy" },
        candidate_line_7 = { text = "Тож сподіваюсь, це ти", face = "scared" },

        you_eliminated = { text = "Ви втратили життя... мені шкода", face = "dead" },
        player_eliminated = { text = "{player} втратив життя", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Ласкаво просимо, {player}", requiredKeys = {"player"}, face = "happy" },
        intro_button_experiment = { text = "Ви потрапили до Buttons Experiment", face = "normal" },
        intro_tested = { text = "На вас чекає серія випробувань", face = "scared" },
        intro_easy_hard = { text = "Деякі будуть простими. Деякі — ні", face = "dead" },
        intro_begin = { text = "Будьте напоготові. Почнімо", face = "happy" },

        intro_special = { text = "У нас тепер особливі раунди", face = "alien" },
        intro_special2 = { text = "Зараз з'являться три різні ефекти", face = "alien" },
        special_text = { text = "{text}", face = "scared", requiredKeys = {"text"} },
        special_text2 = { text = "{text}", face = "nerd", requiredKeys = {"text"} },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "{survivor} дійшов до кінця", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Чудовий виступ!", face = "shy" },
        survivor_congratulations = { text = "Тут є кнопка, можеш натиснути її", face = "happy" },
    },

    --| FIVE BUTTONS EVENT |--
    five_buttons = {
        intro_part1 = { text = "Зараз з'являться п'ять кнопок", face = "happy" },
        intro_part2 = { text = "Одна з них вбиває", face = "scared" },
        intro_part3 = { text = "Ми почнемо з когось випадкового", face = "shy" },
        first_player = { text = "Перший гравець — {player}", requiredKeys = {"player"}, face = "shy" },
        next_player = { text = "Наступний гравець — {player}", requiredKeys = {"player"}, face = "shy" },
        you_eliminated = { text = "Ви втратили життя", face = "dead" },
        player_eliminated = { text = "{player} втратив життя", requiredKeys = {"player"}, face = "dead" },
        button_safe = { text = "Кнопка була безпечною", face = "happy" },
        press_button = { text = "Натисни кнопку", face = "normal" },
    },
}

return Ukrainian