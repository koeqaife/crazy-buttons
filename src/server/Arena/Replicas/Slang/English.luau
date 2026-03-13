--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local English: DictTemplate = {
    --| MISC |--
    misc = {
        error_occurred = { text = "Game kinda broke...", face = "dead" },
        purchase_not_processed = { text = "Bought it but wait till next time fr", face = "nerd" },
        purchase_processed = { text = "W purchase bro!", face = "nerd" },
        players_left = { text = "Only {count} bros still standing", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Bro is speaking fluent alien rn...", face = "shy" },
        question_for_you = { text = "Lemme ask u something real quick", face = "normal" },
        question_like_aliens = { text = "U vibe with aliens?", face = "alien" },
        oh_no = { text = "Nah that's crazy...", face = "no_mouth" },
        not_nice = { text = "Toxic.....", face = "unamused" },
        happy_face = { text = "W :D", face = "happy" },
        that_is_cool = { text = "Valid.", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = { text = "{p1} and {p2} are boutta throw hands", requiredKeys = {"p1", "p2"}, face = "att_def_tru_icon" },
        rules_are_simple = { text = "Rules are light work", face = "happy" },
        rules = { text = "Attack diffs Trust, Defend blocks Attack, Trust beats Defend", face = "nerd" },
        loser_eliminate = { text = "Loser gets packed up.", face = "dead" },
        choose_your_move = { text = "Pick ur move bro", face = "normal" },
        waiting_for_move = { text = "Waiting for {p1} and {p2} to wake up...", requiredKeys = {"p1", "p2"}, face = "normal" },
        both_did_not_move = { text = "Bro they went AFK. Both are cooked", face = "dead" },
        you_both_chose = { text = "Ain't no way u both picked {btn}", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "They literally both picked {btn}", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "Tie bro, go again", face = "shy" },
        tie_they_choose_again = { text = "Tie, they gotta run it back", face = "shy" },
        att_def = { text = "Skill issue, they blocked u", face = "dead" },
        def_att = { text = "W block, u survived", face = "happy" },
        att_trust = { text = "They trusted and got completely cooked", face = "happy" },
        trust_att = { text = "Bro trusted the ops and died", face = "dead" },
        def_trust = { text = "U literally slipped and died bro", face = "dead" },
        trust_def = { text = "They blocked the air and slipped lmao", face = "happy" },
        won_against = { text = "{won} just sent {lost} to the lobby!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "Reaction check going crazy rn", face = "click_button_icon" },
        reaction_test = { text = "Read and lock in if it says to click", face = "click_button_icon" },
        not_much_time = { text = "U only got 2 seconds bro", face = "no_mouth" },
        be_ready = { text = "Lock in", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },
        button_says_truth = { text = "BUTTON SAYS TRUTH", face = "click_button_icon" },
        button_says_lie = { text = "BUTTON SAYS LIE", face = "click_button_icon" },
        you_had_to_click = { text = "Bro fell asleep, u had to click", face = "dead" },
        you_had_to_not_click = { text = "Why u spam clicking bro", face = "dead" },
        you_survived = { text = "U lived fr", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "Speed run test rn", face = "click_button_icon" },
        last_num_eliminate = { text = "Last {num} to click get cooked", requiredKeys = {"num"}, face = "dead" },
        click_faster = { text = "U have to spam it", face = "scared" },
        you_have_to_click = { text = "The button will spawn now", face = "click_button_icon" },
        you_did_not_click = { text = "Go home bruh", face = "angry" },
        you_clicked_too_slow = { text = "Turtle speed bro", face = "scared" },
        you_survived = { text = "U lived", face = "happy" },
        you_are_eliminated = { text = "U got packed up", face = "dead" },
        wait_for_others = { text = "Waiting for the bros", face = "dead" },
        wait_for_green = { text = "Wait for the green light", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Brain check time", icon = "color_event_icon" },
        for_dead_start = { text = "They gotta remember a color", face = "color_event_icon" },
        you_remember_color = { text = "U remember ur color bro?", face = "color_event_icon" },
        lets_check = { text = "Let's see if u got brain cells", face = "shy" },
        did_not_choose = { text = "Bro didn't even pick...", face = "laughing" },
        so_lucky = { text = "Plot armor is crazy!", face = "angry" },
        which_one_you_chose = { text = "So what did u pick?", face = "nerd" },
        wrong_color = { text = "Nah that's wrong", face = "dead" },
        correct_color = { text = "Bro actually remembers!", face = "happy" },
        good_job = { text = "W brain", face = "shy" },
        about_to_show_colors = { text = "Look at these colors bro", face = "color_event_icon" },
        remember_color = { text = "Keep it in mind, u'll need it", face = "normal" },
        choose = { text = "Pick ur favorite one", face = "nerd" },
        red = { text = "Red? Tryhard vibes", face = "happy" },
        blue = { text = "Blue, basic but valid", face = "happy" },
        pink = { text = "Pink, W choice", face = "happy" },
        yellow = { text = "Yellow... bro likes bananas?", face = "happy" },
        green = { text = "Green, touch grass bro...", face = "happy" },
        nothing = { text = "AFK? Color gonna be {color}", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Simon says but combo rn. Most errors get packed", face = "combo_event_icon" },
        repeat_after_me = { text = "Copy this exactly bro", face = "combo_event_icon" },
        players_to_eliminate = { text = "Most errors gets sent to lobby", face = "dead" },
        lets_start = { text = "Let's go", face = "shy" },
        my_turn = { text = "Watch me cook", face = "normal" },
        your_turn = { text = "Ur turn bro", face = "nerd" },
        clicks_left = { text = "{num} clicks left", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Waiting for the slow bros", face = "normal" },
        mistakes_count = { text = "Bro got {num} mistakes...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Let's see the stats", face = "scared" },
        you_eliminated = { text = "U got cooked", face = "dead" },
        you_survived = { text = "U clutched up", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "Duel 1v1 with {p1} vs {p2}", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "Fastest clicker survives", face = "normal" },
        you_did_not_click = { text = "Bro didn't even click", face = "angry" },
        you_are_eliminated = { text = "Packed up", face = "dead" },
        good_job = { text = "W.", face = "shy" },
        you_were_fast_enough = { text = "U were fast enough, nice", face = "happy" },
        you_are_slow = { text = "Learn to click faster", face = "laughing" },
        won = { text = "{player} caught a massive W", face = "happy", requiredKeys = {"player"} },
        wait_for_green = { text = "Wait until the button turns green", face = { text = "..." } }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "Click or nah, 50/50 rng bro", face = "even_odd_event_icon" },
        intro_alive = { text = "Ur choice, press or skip", face = "even_odd_event_icon" },
        intro_counting = { text = "Boutta count em up", face = "nerd" },
        intro_odd = { text = "If odd, clickers get cooked", face = "even_odd_event_icon" },
        intro_even = { text = "If even, non-clickers get cooked", face = "even_odd_event_icon" },
        remember_to_talk = { text = "Use the chat", face = "shy" },
        time_to_count = { text = "Counting rn", face = "scared" },
        player_clicked = { text = "{player} clicked", requiredKeys = {"player"}, face = "normal" },
        count_even = { text = "It's even bro", face = "normal" },
        count_odd = { text = "It's odd bro", face = "normal" },
        you_survived = { text = "U survived", face = "happy" },
        you_are_eliminated = { text = "U got packed", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "They are searching for button now", face = "laughing" },
        intro_ready = { text = "Ready to look?", face = "happy" },
        intro_100_buttons = { text = "100 buttons fr, it's crazy", face = "scared" },
        intro_first_rewarded = { text = "First to find gets a massive W", face = "shy" },
        good_luck = { text = "Good luck finding it bro", face = "laughing" },
        you_found_god_btn = { text = "Ain't no way u found it!", face = "happy" },
        someone_found_god_btn = { text = "{player} actually found it", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Blind bros... no one found it", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Free loot incoming bro", face = "laughing" },
        intro_alive_part1 = { text = "Somebody boutta get blessed", face = "happy" },
        intro_alive_part2 = { text = "Who's it gonna be.......", face = "scared" },
        dead_who_got = { text = "{player} got the free loot.", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "U bro!", face = "happy" },
        you_got_tool_part2 = { text = "Click that new button rn", face = "shy" },
        you_got_tool_part3 = { text = "And click on a W player!!", face = "no_mouth" },
        you_got_tool_part4 = { text = "Confetti boutta drop I swear", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "Bro got the loot now", face = "happy" },
        someone_got_tool_part3 = { text = "Massive W right?", face = "shy" },
        someone_got_tool_part4 = { text = "Good luck bro", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Duo queue active fr", face = "scared" },
        intro_part2 = { text = "One dies, both die. Tough", face = "dead" },
        intro_part3 = { text = "Picking the duo", face = "shy" },
        first_player_is = { text = "First bro is...", face = "normal" },
        second_player_is = { text = "Second bro is...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "{player} doing math rn", requiredKeys = {"player"}, face = "nerd" },
        intro_self_q1 = { text = "U smart bro?", face = "nerd" },
        intro_self_q2 = { text = "Their lives literally in ur hands.", face = "scared" },
        intro_others_q1 = { text = "Is {player} actually smart?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Boutta find out.", face = "shy" },
        calculate_this = { text = "Solve:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },
        is_player_smart = { text = "Can {player} do:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },
        you_answer_right = { text = "W answer fr", face = "happy" },
        you_answer_wrong = { text = "L answer bro", face = "scared" },
        you_not_believed = { text = "Bro had 0 believers...", face = "dead" },
        you_had_to_answer = { text = "U had to answer bro...", face = "dead" },
        you_wrong_lucky = { text = "Wrong but u got RNG lucky.", face = "happy" },
        you_wrong = { text = "U were wrong fr.", face = "dead" },
        you_right = { text = "U were right.", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "Maze just dropped", face = "normal" },
        intro_part2 = { text = "6 buttons in there", face = "normal" },
        intro_part3 = { text = "1 is a W, 1 is an L", face = "scared" },
        intro_part4 = { text = "Go find it bro.", face = "happy" },
        somebody_awarded = { text = "Someone clutched the W", face = "happy" },
        no_one_awarded = { text = "Nobody got it bro", face = "no_mouth" },
    },

    --| OBBY EVENT |--
    obby = {
        intro_part1 = { text = "Just dropped a crazy", face = "normal" },
        intro_part2 = { text = "Button at the very end", face = "normal" },
        intro_part3 = { text = "First one there catches a massive W", face = "scared" },
        intro_part4 = { text = "Slowest bro gets completely cooked", face = "happy" },
        intro_part5 = { text = "Go!", face = "dead" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Someone's respawning rn", face = "shy" },
        player_revived = { text = "{player} just respawned", requiredKeys = {"player"}, face = "happy" },
        intro_vote_common = { text = "Chat is voting for a revive", face = "shy" },
        intro_vote_candidate = { text = "Will chat revive u tho...", face = "shy" },
        intro_dead_not_you = { text = "Not u tho rip...", face = "no_mouth" },
        intro_choose_wise = { text = "Vote carefully", face = "nerd" },
        you_are_revived = { text = "U are respawned!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = { text = "Sacrifice for {p1} and {p2}", requiredKeys = {"p1", "p2"}, face = "scared" },
        chosen_you_1 = { text = "U got picked bro...", face = "scared" },
        chosen_you_2 = { text = "Someone gotta take the L to save u", face = "scared" },
        chosen_others_1 = { text = "{p1} and {p2} are completely cooked", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "U gonna be the hero and save em?", face = "shy" },
        press_to_save = { text = "Press to save.", face = "shy" },
        choice_cannot_be_undone = { text = "No takesies backsies bro", face = "dead" },
        you_are_eliminated = { text = "U took the L for them", face = "dead" },
        they_are_eliminated = { text = "They got packed", face = "scared" },
        you_are_saved = { text = "U survived", face = "happy" },
        you_saved_them = { text = "W teammate, u saved em", face = "dead" },
        they_were_saved = { text = "{p1} and {p2} lived!", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "Simon says rn", face = "nerd" },
        intro_alive_1 = { text = "Bro thinks he's Simon (I am)", face = "shy" },
        intro_alive_2 = { text = "No 'Simon says' = do the opposite", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Split or Steal w/ {p2} rn", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} and {p2} up next", requiredKeys = {"p1","p2"}, face = "happy" },
        rule_both_split = { text = "Both split = chill", face = "happy" },
        rule_one_steal = { text = "One steals = other is cooked", face = "scared" },
        rule_both_steal = { text = "Both steal = double L", face = "laughing" },
        rule_both_steal_others = { text = "Both steal = both cooked", face = "laughing" },
        choose_wisely = { text = "Lock in bro", face = "nerd" },
        waiting_for_players = { text = "Waiting for them to lock in", face = "normal" },
        both_steal = { text = "Both stole lmao, double L", face = "laughing" },
        stealer_chosen = { text = "{stealer} did {victim} dirty", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "W split, both lived", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "U got the L button", face = "shy" },
        intro_killer_2 = { text = "Cooks anyone who clicks it", face = "scared" },
        intro_killer_3 = { text = "Trick em into clicking it", face = "normal" },
        intro_saver_1 = { text = "U got the W button", face = "shy" },
        intro_saver_2 = { text = "Saves anyone who clicks it", face = "happy" },
        intro_saver_3 = { text = "Make em click it", face = "normal" },
        intro_others_1 = { text = "Talk to {p1} and {p2}", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "One is literally an op", face = "normal" },
        intro_others_3 = { text = "So who?", face = "nerd" },
        lets_see = { text = "Let's see who dropped...", face = "normal" },
        result_no_choice = { text = "AFK = L. U got packed", face = "dead" },
        result_chose_died = { text = "U picked {p}'s button, u got cooked", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "U picked {p}'s button, ur safe fr", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "Vote to kick somebody", face = "shy" },
        intro_common_1 = { text = "Chat is voting who to kick", face = "normal" },
        intro_candidate_fate = { text = "Chat decides ur fate bro...", face = "scared" },
        intro_choose_wise = { text = "Vote who you wont to get cooked", face = "happy" },
        candidate_line_1 = { text = "Boring there?", face = "normal" },
        candidate_line_2 = { text = "Bros are crazy", face = "shy" },
        candidate_line_3 = { text = "They voting based on ur avatar", face = "normal" },
        candidate_line_4 = { text = "Or cuz u were toxic before", face = "scared" },
        candidate_line_5 = { text = "U know how it is", face = "normal" },
        candidate_line_6 = { text = "U chill with them right?", face = "shy" },
        candidate_line_7 = { text = "Let's see who got cooked", face = "scared" },
        you_eliminated = { text = "U got voted out...", face = "dead" },
        player_eliminated = { text = "{player} got packed", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Yo {player} what's good!", requiredKeys = {"player"}, face = "shy" },
        intro_button_experiment = { text = "Welcome to the Button Experiment", face = "normal" },
        intro_tested = { text = "Gonna put u in some crazy situations", face = "scared" },
        intro_easy_hard = { text = "Some are light, some gonna cook u", face = "dead" },
        intro_begin = { text = "Let's go!", face = "happy" },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "Ain't no way {survivor} made it to the end", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Bro clutched a 1v99...", face = "shy" },
        survivor_congratulations = { text = "Massive W, u survived!", face = "happy" },
    }
}

return English