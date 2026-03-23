--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local English: DictTemplate = {
    --| MISC |--
    misc = {
        error_occurred = { text = "We cannot continue this round, sorry for that", face = "dead" },
        purchase_not_processed = { text = "Your purchase has been processed, but it can't be used right now. Next time it's free", face = "nerd" },
        purchase_processed = { text = "Your purchase has been processed!", face = "nerd" },
        players_left = { text = "{count} subjects are left", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "They're answering to some secret question...", face = "shy" },
        question_for_you = { text = "I have a question for you", face = "normal" },
        question_like_aliens = { text = "Do you like aliens?", face = "alien" },
        oh_no = { text = "Oh no...", face = "no_mouth" },
        not_nice = { text = "That's not nice.....", face = "unamused" },
        happy_face = { text = ":D", face = "happy" },
        that_is_cool = { text = "That's cool", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = {
            text = "{p1} and {p2} will play Attack, Defend, Trust",
            requiredKeys = {"p1", "p2"},
            face = "att_def_tru_icon"
        },
        rules_are_simple = { text = "Rules are simple", face = "happy" },
        rules = { text = "Attack beats Trust, Defend beats Attack, Trust beats Defend", face = "nerd" },
        loser_eliminate = { text = "The loser will be eliminated", face = "dead" },
        choose_your_move = { text = "Choose your move", face = "normal" },
        waiting_for_move = {
            text = "Waiting for {p1} and {p2} to choose their move...",
            requiredKeys = {"p1", "p2"},
            face = "normal"
        },
        both_did_not_move = { text = "Both subjects did not move", face = "dead" },
        you_both_chose = { text = "You both chose {btn}", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "They both chose {btn}", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "It's a tie, choose again", face = "shy" },
        tie_they_choose_again = { text = "It's a tie, they will choose again", face = "shy" },

        att_def = { text = "They defended against your attack", face = "dead" },
        def_att = { text = "You defended against their attack", face = "happy" },

        att_trust = { text = "They trusted too much and got attacked", face = "happy" },
        trust_att = { text = "You got attacked while trying to trust", face = "dead" },

        def_trust = { text = "You slipped while you were trying to defend from air", face = "dead" },
        trust_def = { text = "They slipped while trying to defend from air", face = "happy" },

        won_against = { text = "{won} won against {lost}!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "They have a tricky test with a button", face = "click_button_icon" },
        reaction_test = { text = "Now you have to read and press the button if it says so", face = "click_button_icon" },
        not_much_time = { text = "But you have only two seconds to react", face = "no_mouth" },
        be_ready = { text = "Be ready", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },

        button_says_truth = { text = "BUTTON SAYS TRUTH", face = "click_button_icon" },
        button_says_lie = { text = "BUTTON SAYS LIE", face = "click_button_icon" },

        you_had_to_click = { text = "You should've clicked", face = "dead" },
        you_had_to_not_click = { text = "You shouldn't have to click", face = "dead" },
        you_survived = { text = "You survived", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "They will have to click the button first", face = "click_button_icon" },
        last_num_eliminate = { text = "The last one to click will be eliminated", face = "dead" },
        click_faster = { text = "Click faster than the others", face = "scared" },
        you_have_to_click = { text = "Prepare to press the button as fast as possible", face = "click_button_icon" },

        you_did_not_click = { text = "You didn't press", face = "angry" },
        you_clicked_too_slow = { text = "That was slow", face = "scared" },

        you_survived = { text = "You survived", face = "happy" },
        you_are_eliminated = { text = "You are eliminated", face = "dead" },
        wait_for_others = { text = "Wait for others to click", face = "dead" },
        wait_for_green = { text = "Wait until the button turns green", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "They're getting checked if they remember the color", icon = "color_event_icon" },
        for_dead_start = { text = "They're asked to remember a color", face = "color_event_icon" },
        you_remember_color = { text = "Do you remember the color you chose before?", face = "color_event_icon" },
        lets_check = { text = "Let's check your memory", face = "shy" },

        did_not_choose = { text = "Looks like you didn't get too choose color...", face = "laughing" },
        so_lucky = { text = "So lucky!", face = "angry" },

        which_one_you_chose = { text = "Remember which one you chose before?", face = "nerd" },
        wrong_color = { text = "You are wrong.", face = "dead" },
        correct_color = { text = "Smart head, you remember!", face = "happy" },
        good_job = { text = "Good job", face = "shy" },

        about_to_show_colors = { text = "I will show you 3 colors", face = "color_event_icon" },
        remember_color = { text = "Pick the color and remember it", face = "normal" },
        choose = { text = "Pick now", face = "nerd" },

        red = { text = "Very interesting", face = "happy" },
        blue = { text = "So the color of the sky, I see", face = "happy" },
        pink = { text = "Why? It looks yummy though", face = "happy" },
        yellow = { text = "You like bananas?", face = "happy" },
        green = { text = "The color of the nature, good choice", face = "happy" },
        nothing = { text = "Nothing? Let's go with {color} then", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "They will repeat the sequence now", face = "combo_event_icon" },
        repeat_after_me = { text = "Now you will have to repeat the sequence after me", face = "combo_event_icon" },
        players_to_eliminate = { text = "Subjects with the highest amount of mistakes will be eliminated", face = "dead" },
        lets_start = { text = "Let's start", face = "shy" },
        my_turn = { text = "My turn, watch closely", face = "normal" },
        your_turn = { text = "Your turn", face = "nerd" },
        clicks_left = { text = "{num} clicks left", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Let's wait for others to finish", face = "normal" },
        mistakes_count = { text = "You have {num} mistakes...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Let's see what we got here", face = "scared" },

        you_eliminated = { text = "You are the one of people who are eliminated", face = "dead" },
        you_survived = { text = "You survived", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "{p1} and {p2} will play deadly duel now", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "The fastest subject survives", face = "normal" },
        you_did_not_click = { text = "You didn't press", face = "angry" },
        you_are_eliminated = { text = "You are eliminated", face = "dead" },
        good_job = { text = "Good job", face = "shy" },
        you_were_fast_enough = { text = "Looks like you die now", face = "happy" },  -- Changed both to make fun of them
        you_are_slow = { text = "Oh, that was fast!", face = "laughing" },
        won = { text = "{player} won this duel", face = "happy", requiredKeys = {"player"} },
        wait_for_green = { text = "Wait until the button turns green", face = { text = "..." } }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "They will decide whether to press the button or not", face = "even_odd_event_icon" },
        intro_alive = { text = "You will decide whether to press the button or not", face = "even_odd_event_icon" },
        intro_counting = { text = "After, I'll count the presses", face = "nerd" },
        intro_odd = { text = "If the total is odd, all who pressed are eliminated", face = "even_odd_event_icon" },
        intro_even = { text = "If it's even, those who didn't press are eliminated", face = "even_odd_event_icon" },

        remember_to_talk = { text = "Remember to talk with others", face = "shy" },

        time_to_count = { text = "Time to count", face = "scared" },
        player_clicked = { text = "{player} clicked", requiredKeys = {"player"}, face = "normal" },

        count_even = { text = "It's even", face = "normal" },
        count_odd = { text = "It's odd", face = "normal" },

        you_survived = { text = "You survived", face = "happy" },
        you_are_eliminated = { text = "You're eliminated", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "100 buttons appeared", face = "laughing" },
        intro_ready = { text = "Be ready to search", face = "happy" },
        intro_100_buttons = { text = "100 buttons will fall down of the sky", face = "scared" },
        intro_first_rewarded = { text = "One button gives you something cool", face = "shy" },
        good_luck = { text = "Good luck finding it", face = "laughing" },
        you_found_god_btn = { text = "You found the button!", face = "happy" },
        someone_found_god_btn = { text = "{player} found the button", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "No one found the button, hahaha", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Someone will get a gift", face = "laughing" },
        intro_alive_part1 = { text = "One subject will get a gift now", face = "happy" },
        intro_alive_part2 = { text = "And it will be......", face = "scared" },
        dead_who_got = { text = "{player} got a gift", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "You!", face = "happy" },
        you_got_tool_part2 = { text = "So there is a gray button, press on it", face = "shy" },
        you_got_tool_part3 = { text = "And after that click on somebody you like", face = "no_mouth" },
        you_got_tool_part4 = { text = "Very pretty confetti will appear", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "They're happy with their gift now", face = "happy" },
        someone_got_tool_part3 = { text = "It's very cool", face = "shy" },
        someone_got_tool_part4 = { text = "Make them mad", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "I will link two people together now", face = "scared" },
        intro_part2 = { text = "If one dies the other dies too", face = "dead" },
        intro_part3 = { text = "I hope it's gonna be you hahah", face = "normal" },
        first_player_is = { text = "The first subject is...", face = "normal" },
        second_player_is = { text = "The second subject is...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "{player} will do math quiz now", requiredKeys = {"player"}, face = "nerd" },

        intro_self_q1 = { text = "You think you're smart?", face = "nerd" },
        intro_self_q2 = { text = "Somebody will die if they think otherwise", face = "scared" },

        intro_others_q1 = { text = "Do you think {player} is good in math?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "You will have to find out", face = "shy" },

        calculate_this = { text = "Calculate this now:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },

        is_player_smart = { text = "Is {player} smart enough to calculate:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },

        you_answer_right = { text = "Your answer was right", face = "happy" },
        you_answer_wrong = { text = "Your answer was wrong", face = "scared" },

        you_not_believed = { text = "But no one even believed in you...", face = "dead" },
        you_had_to_answer = { text = "You had to answer...", face = "dead" },
        you_wrong_lucky = { text = "You were wrong, but lucky this time", face = "happy" },
        you_wrong = { text = "You were wrong", face = "dead" },
        you_right = { text = "You were right", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "A maze just appeared", face = "normal" },
        intro_part2 = { text = "There are exactly 6 buttons", face = "normal" },
        intro_part3 = { text = "One of them is dangerous, other is useful", face = "scared" },
        intro_part4 = { text = "Good luck searching", face = "happy" },
        somebody_awarded = { text = "Somebody was awarded", face = "happy" },
        no_one_awarded = { text = "No one was awarded", face = "no_mouth" },
    },

    --| OBBY EVENT |--
    obby = {
        intro_part1 = { text = "I just spawned some really easy challenge", face = "normal" },
        intro_part2 = { text = "There is one button in the end", face = "normal" },
        intro_part3 = { text = "Be the first one to press it to get something cool", face = "scared" },
        intro_part4 = { text = "The last one to press it will get really bad dream", face = "happy" },
        intro_part5 = { text = "Don't waste your time here", face = "dead" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Someone random will get back to life now", face = "shy" },
        player_revived = { text = "And it is {player}", requiredKeys = {"player"}, face = "happy" },

        intro_vote_common = { text = "Do you want somebody to come back?", face = "shy" },
        intro_vote_candidate = { text = "Subjects will decide if it's you", face = "shy" },
        intro_dead_not_you = { text = "Someone but not you will definitely will", face = "no_mouth" },
        intro_choose_wise = { text = "Even if not, you have to choose", face = "nerd" },

        you_are_revived = { text = "Say hi to everyone!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = {
            text = "They will need to sacrifice for {p1} and {p2}",
            requiredKeys = {"p1", "p2"},
            face = "scared"
        },

        chosen_you_1 = { text = "Your life can end now", face = "scared" },
        chosen_you_2 = { text = "Someone has to sacrifice to save you", face = "scared" },

        chosen_others_1 = { text = "{p1} and {p2} are chosen.", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "Will you sacrifice to save them?", face = "shy" },

        press_to_save = { text = "Press to save them", face = "shy" },
        choice_cannot_be_undone = { text = "Your choice cannot be undone", face = "dead" },

        you_are_eliminated = { text = "Goodbye", face = "dead" },
        they_are_eliminated = { text = "Say goodbye to them", face = "scared" },

        you_are_saved = { text = "That's sad, you're alive...", face = "angry" },
        you_saved_them = { text = "You're such a nice person", face = "dead" },
        they_were_saved = { text = "{p1} and {p2} are good now", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "They're listening to Simon now", face = "nerd" },
        intro_alive_1 = { text = "I'm Simon now, follow my commands carefully", face = "shy" },
        intro_alive_2 = { text = "Do the opposite if I didn't say 'Simon says'", face = "nerd" },
        intro_alive_3 = { text = "When I say 'select', click the button so it gets highlighted", face = "nerd" },
        intro_alive_4 = { text = "Let's begin with something simple", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Be friends with {p2}", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} and {p2} have to split or steal now", requiredKeys = {"p1","p2"}, face = "happy" },

        rule_both_split = { text = "If both split, nothing happens", face = "happy" },
        rule_one_steal = { text = "If one steals, the other dies", face = "scared" },
        rule_both_steal = { text = "If both steal, you both die", face = "laughing" },
        rule_both_steal_others = { text = "If both steal, they both die", face = "laughing" },

        choose_wisely = { text = "Choose wisely", face = "nerd" },
        waiting_for_players = { text = "Waiting for the subjects to decide", face = "normal" },

        both_steal = { text = "Both subjects chose to steal, they both die", face = "laughing" },
        stealer_chosen = { text = "{stealer} chose to steal, {victim} is eliminated", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Both subjects chose to split, they both survive", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "Your button is bad", face = "shy" },
        intro_killer_2 = { text = "Everybody who clicks it, dies", face = "scared" },
        intro_killer_3 = { text = "Try to convince others to click it for you (your is bad)", face = "normal" },

        intro_saver_1 = { text = "Your button is very normal", face = "shy" },
        intro_saver_2 = { text = "Everybody who clicks it, doesn't die", face = "happy" },
        intro_saver_3 = { text = "Try to convince others to click it for you (your is good)", face = "normal" },

        intro_others_1 = { text = "You have to talk with {p1} and {p2}", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "One of them has a button that kills you", face = "normal" },
        intro_others_3 = { text = "So who do you believe?", face = "nerd" },

        lets_see = { text = "Let's see who died...", face = "normal" },

        result_no_choice = { text = "You didn't choose a button, you died", face = "dead" },
        result_chose_died = { text = "You chose {p}'s button, you died", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "You chose {p}'s button, you are safe", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "They're voting for who to eliminate", face = "shy" },

        intro_common_1 = { text = "Time to vote for elimination", face = "normal" },
        intro_candidate_fate = { text = "Others will decide your fate.", face = "scared" },
        intro_choose_wise = { text = "Choose somebody you don't like", face = "happy" },

        candidate_line_1 = { text = "So I see they are voting", face = "normal" },
        candidate_line_2 = { text = "The most voted will be eliminated", face = "shy" },
        candidate_line_3 = { text = "What do you think, do they like you?", face = "normal" },
        candidate_line_4 = { text = "Imagine if they don't", face = "scared" },
        candidate_line_5 = { text = "You will lose this game haha", face = "normal" },
        candidate_line_6 = { text = "And losing the experiment is so bad", face = "shy" },
        candidate_line_7 = { text = "So I hope that's you", face = "scared" },

        you_eliminated = { text = "You were eliminated... I'm sorry", face = "dead" },
        player_eliminated = { text = "{player} was eliminated", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Hello {player}", requiredKeys = {"player"}, face = "unamused" },
        intro_button_experiment = { text = "Welcome to the Button Experiment", face = "normal" },
        intro_tested = { text = "We will test you.", face = "scared" },
        intro_easy_hard = { text = "Don't think it will be easy", face = "dead" },
        intro_begin = { text = "Let's begin", face = "happy" },
        intro_special = { text = "We have special rounds now", face = "alien" },
        intro_special2 = { text = "Three different effects will present now", face = "alien" },
        special_text = { text = "{text}", face = "scared", requiredKeys = {"text"} },
        special_text2 = { text = "{text}", face = "nerd", requiredKeys = {"text"} },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "{survivor} made it to the end", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Very good performance!", face = "shy" },
        survivor_congratulations = { text = "There is a button, you can press it", face = "happy" },
    },

    --| FIVE BUTTONS EVENT |--
    five_buttons = {
        intro_part1 = { text = "Five buttons will appear now", face = "happy" },
        intro_part2 = { text = "One of them kills", face = "scared" },
        intro_part3 = { text = "We will start with somebody random", face = "shy" },
        first_player = { text = "The first player is {player}", requiredKeys = {"player"}, face = "shy" },
        next_player = { text = "The next player is {player}", requiredKeys = {"player"}, face = "shy" },
        you_eliminated = { text = "You are eliminated", face = "dead" },
        player_eliminated = { text = "{player} was eliminated", requiredKeys = {"player"}, face = "dead" },
        button_safe = { text = "Button was safe", face = "happy" },
        press_button = { text = "Press the button", face = "normal" },
    },
}

return English