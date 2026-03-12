--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local English: DictTemplate = {
    --| MISC |--
    misc = {
        error_occurred = { text = "System failure detected...", face = "dead" },
        purchase_not_processed = { text = "Funds acquired. Item delayed until next cycle.", face = "nerd" },
        purchase_processed = { text = "Transaction accepted.", face = "nerd" },
        players_left = { text = "{count} subjects remain.", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Processing extraterrestrial frequencies...", face = "shy" },
        question_for_you = { text = "I have a data query for you.", face = "normal" },
        question_like_aliens = { text = "Are alien lifeforms appealing to you?", face = "alien" },
        oh_no = { text = "Predictably unfortunate...", face = "no_mouth" },
        not_nice = { text = "Hostile behavior detected.....", face = "unamused" },
        happy_face = { text = "Processing joy...", face = "happy" },
        that_is_cool = { text = "Fascinating.", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = { text = "Subjects {p1} and {p2} selected for combat.", requiredKeys = {"p1", "p2"}, face = "att_def_tru_icon" },
        rules_are_simple = { text = "The parameters are simple.", face = "happy" },
        rules = { text = "Attack destroys Trust. Defend blocks Attack. Trust bypasses Defend.", face = "nerd" },
        loser_eliminate = { text = "The inferior subject will be terminated.", face = "dead" },
        choose_your_move = { text = "Input your decision.", face = "normal" },
        waiting_for_move = { text = "Awaiting input from {p1} and {p2}...", requiredKeys = {"p1", "p2"}, face = "normal" },
        both_did_not_move = { text = "Inaction detected. Both terminated.", face = "dead" },
        you_both_chose = { text = "Mutual input: {btn}.", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "They both inputted {btn}.", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "Stalemate. Recalculating...", face = "shy" },
        tie_they_choose_again = { text = "Stalemate. They must input again.", face = "shy" },
        att_def = { text = "Your assault was easily blocked.", face = "dead" },
        def_att = { text = "You successfully deflected damage.", face = "happy" },
        att_trust = { text = "Trust is a flaw. They were eliminated.", face = "happy" },
        trust_att = { text = "You trusted. You were destroyed.", face = "dead" },
        def_trust = { text = "Defending against nothing? Pathetic.", face = "dead" },
        trust_def = { text = "They defended against thin air.", face = "happy" },
        won_against = { text = "Subject {won} eliminated {lost}.", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "They are undergoing a reflex diagnostic.", face = "click_button_icon" },
        reaction_test = { text = "Read instructions carefully and input if required.", face = "click_button_icon" },
        not_much_time = { text = "You have exactly two seconds.", face = "no_mouth" },
        be_ready = { text = "Prepare.", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },
        button_says_truth = { text = "BUTTON SAYS TRUE", face = "click_button_icon" },
        button_says_lie = { text = "BUTTON SAYS FALSE", face = "click_button_icon" },
        you_had_to_click = { text = "Failure to input.", face = "dead" },
        you_had_to_not_click = { text = "Invalid input detected.", face = "dead" },
        you_survived = { text = "Survival confirmed.", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "They must input via the button now.", face = "click_button_icon" },
        last_num_eliminate = { text = "The slowest {num} subjects will be terminated.", requiredKeys = {"num"}, face = "dead" },
        click_faster = { text = "Maximize your reaction speed.", face = "scared" },
        you_have_to_click = { text = "Mandatory input required now.", face = "click_button_icon" },
        you_did_not_click = { text = "Input missing.", face = "angry" },
        you_clicked_too_slow = { text = "Insufficient speed detected.", face = "scared" },
        you_survived = { text = "Survival confirmed.", face = "happy" },
        you_are_eliminated = { text = "Termination confirmed.", face = "dead" },
        wait_for_others = { text = "Awaiting other subjects.", face = "dead" },
        wait_for_green = { text = "Await the green visual signal.", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Cognitive memory diagnostic in progress.", icon = "color_event_icon" },
        for_dead_start = { text = "They must memorize a visual wavelength.", face = "color_event_icon" },
        you_remember_color = { text = "Do you recall your selected hue?", face = "color_event_icon" },
        lets_check = { text = "Testing cognitive function.", face = "shy" },
        did_not_choose = { text = "No initial input detected...", face = "laughing" },
        so_lucky = { text = "Statistical anomaly.", face = "angry" },
        which_one_you_chose = { text = "Input your previous selection.", face = "nerd" },
        wrong_color = { text = "Incorrect memory recall.", face = "dead" },
        correct_color = { text = "Acceptable cognitive function.", face = "happy" },
        good_job = { text = "Adequate.", face = "shy" },
        about_to_show_colors = { text = "Displaying visual wavelengths.", face = "color_event_icon" },
        remember_color = { text = "Memorize your selection for later diagnostic.", face = "normal" },
        choose = { text = "Select your preferred hue.", face = "nerd" },
        red = { text = "Red. Aggressive.", face = "happy" },
        blue = { text = "Blue. Standard.", face = "happy" },
        pink = { text = "Pink. Irrelevant.", face = "happy" },
        yellow = { text = "Yellow. Adequate.", face = "happy" },
        green = { text = "Green. Biological.", face = "happy" },
        nothing = { text = "Defaulting selection to {color}.", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Sequence replication active. Terminations imminent.", face = "combo_event_icon" },
        repeat_after_me = { text = "Replicate the exact sequence provided.", face = "combo_event_icon" },
        players_to_eliminate = { text = "Subjects with the highest error rate will be terminated.", face = "dead" },
        lets_start = { text = "Initializing.", face = "shy" },
        my_turn = { text = "Observe sequence carefully.", face = "normal" },
        your_turn = { text = "Replicate now.", face = "nerd" },
        clicks_left = { text = "{num} inputs remain.", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Awaiting completion from others.", face = "normal" },
        mistakes_count = { text = "{num} errors logged...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Analyzing data.", face = "scared" },
        you_eliminated = { text = "Error limit exceeded. Terminated.", face = "dead" },
        you_survived = { text = "Acceptable performance. Survived.", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "Subjects {p1} and {p2} are in a fatal duel.", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "First input ensures survival.", face = "normal" },
        you_did_not_click = { text = "Input missing.", face = "angry" },
        you_are_eliminated = { text = "Termination confirmed.", face = "dead" },
        good_job = { text = "Adequate.", face = "shy" },
        you_were_fast_enough = { text = "Speed was sufficient.", face = "happy" },
        you_are_slow = { text = "Opponent was superior.", face = "laughing" },
        won = { text = "Subject {player} is victorious.", face = "happy", requiredKeys = {"player"} }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "Binary decision diagnostic initiated.", face = "even_odd_event_icon" },
        intro_alive = { text = "Input decision: press or do not press.", face = "even_odd_event_icon" },
        intro_counting = { text = "Tabulating total inputs shortly.", face = "nerd" },
        intro_odd = { text = "Odd sum equals termination for all who pressed.", face = "even_odd_event_icon" },
        intro_even = { text = "Even sum equals termination for all who abstained.", face = "even_odd_event_icon" },
        remember_to_talk = { text = "Verbal strategy is permitted.", face = "shy" },
        time_to_count = { text = "Tabulating.", face = "scared" },
        player_clicked = { text = "Subject {player} provided input.", requiredKeys = {"player"}, face = "normal" },
        count_even = { text = "Result is even.", face = "normal" },
        count_odd = { text = "Result is odd.", face = "normal" },
        you_survived = { text = "Survival confirmed.", face = "happy" },
        you_are_eliminated = { text = "Termination confirmed.", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "Needle in a haystack protocol initiated.", face = "laughing" },
        intro_ready = { text = "Prepared to search?", face = "happy" },
        intro_100_buttons = { text = "100 variables generated.", face = "scared" },
        intro_first_rewarded = { text = "First to locate the target is rewarded.", face = "shy" },
        good_luck = { text = "Commence search.", face = "laughing" },
        you_found_god_btn = { text = "Target acquired.", face = "happy" },
        someone_found_god_btn = { text = "Subject {player} acquired target.", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Target unlocated. Incompetence.", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "Item distribution protocol active.", face = "laughing" },
        intro_alive_part1 = { text = "One subject will be granted an item.", face = "happy" },
        intro_alive_part2 = { text = "Calculating recipient...", face = "scared" },
        dead_who_got = { text = "Subject {player} obtained item.", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "Subject identified.", face = "happy" },
        you_got_tool_part2 = { text = "Input required on the new interface.", face = "shy" },
        you_got_tool_part3 = { text = "Target another subject.", face = "no_mouth" },
        you_got_tool_part4 = { text = "Visual effect will deploy.", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}.", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "They possess an item.", face = "happy" },
        someone_got_tool_part3 = { text = "Acceptable outcome.", face = "shy" },
        someone_got_tool_part4 = { text = "Proceed.", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Subject linkage protocol active.", face = "scared" },
        intro_part2 = { text = "Mutual termination condition enabled.", face = "dead" },
        intro_part3 = { text = "Calculating optimal targets.", face = "shy" },
        first_player_is = { text = "Subject one is...", face = "normal" },
        second_player_is = { text = "Subject two is...", face = "normal" },
        player = { text = "{player}", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "Subject {player} is undergoing cognitive evaluation.", requiredKeys = {"player"}, face = "nerd" },
        intro_self_q1 = { text = "Mathematics proficiency check.", face = "nerd" },
        intro_self_q2 = { text = "Other subjects' survival depends on your intellect.", face = "scared" },
        intro_others_q1 = { text = "Does {player} possess adequate intelligence?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Evaluation required.", face = "shy" },
        calculate_this = { text = "Compute:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },
        is_player_smart = { text = "Can {player} accurately calculate:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },
        you_answer_right = { text = "Calculation correct.", face = "happy" },
        you_answer_wrong = { text = "Calculation incorrect.", face = "scared" },
        you_not_believed = { text = "Lack of faith noted.", face = "dead" },
        you_had_to_answer = { text = "Input was mandatory...", face = "dead" },
        you_wrong_lucky = { text = "Incorrect, but statistical luck saved you.", face = "happy" },
        you_wrong = { text = "Incorrect computation.", face = "dead" },
        you_right = { text = "Correct computation.", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "Labyrinth generated.", face = "normal" },
        intro_part2 = { text = "6 interactive nodes present.", face = "normal" },
        intro_part3 = { text = "1 node is lethal. 1 provides a reward.", face = "scared" },
        intro_part4 = { text = "Commence navigation.", face = "happy" },
        somebody_awarded = { text = "Reward dispensed.", face = "happy" },
        no_one_awarded = { text = "No rewards dispensed.", face = "no_mouth" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "Random reanimation protocol active.", face = "shy" },
        player_revived = { text = "Subject {player} reanimated.", requiredKeys = {"player"}, face = "happy" },
        intro_vote_common = { text = "Democratic reanimation initiated.", face = "shy" },
        intro_vote_candidate = { text = "Subjects will decide the target...", face = "shy" },
        intro_dead_not_you = { text = "You are excluded from eligibility.", face = "no_mouth" },
        intro_choose_wise = { text = "Select your target carefully.", face = "nerd" },
        you_are_revived = { text = "You are reanimated.", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = { text = "Altruism test for {p1} and {p2}.", requiredKeys = {"p1", "p2"}, face = "scared" },
        chosen_you_1 = { text = "You are the primary variable...", face = "scared" },
        chosen_you_2 = { text = "Termination of another is required to save you.", face = "scared" },
        chosen_others_1 = { text = "{p1} and {p2} are targeted.", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "Will you initiate self-termination to save them?", face = "shy" },
        press_to_save = { text = "Input to preserve them.", face = "shy" },
        choice_cannot_be_undone = { text = "This decision is irreversible.", face = "dead" },
        you_are_eliminated = { text = "Termination confirmed.", face = "dead" },
        they_are_eliminated = { text = "Targets terminated.", face = "scared" },
        you_are_saved = { text = "Subject preserved.", face = "happy" },
        you_saved_them = { text = "You preserved them.", face = "dead" },
        they_were_saved = { text = "{p1} and {p2} preserved.", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "Obedience diagnostic active.", face = "nerd" },
        intro_alive_1 = { text = "I am Simon now.", face = "shy" },
        intro_alive_2 = { text = "Missing \"Simon says\"? Perform inverse action.", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "Prisoner's dilemma with {p2}.", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "Subjects {p1} and {p2} selected.", requiredKeys = {"p1","p2"}, face = "happy" },
        rule_both_split = { text = "Mutual split is neutral.", face = "happy" },
        rule_one_steal = { text = "Asymmetric input is lethal to the victim.", face = "scared" },
        rule_both_steal = { text = "Mutual greed terminates both.", face = "laughing" },
        rule_both_steal_others = { text = "Mutual greed terminates both subjects.", face = "laughing" },
        choose_wisely = { text = "Logical choice required.", face = "nerd" },
        waiting_for_players = { text = "Awaiting subject inputs.", face = "normal" },
        both_steal = { text = "Mutual steal detected. Both terminated.", face = "laughing" },
        stealer_chosen = { text = "{stealer} betrayed {victim}. {victim} terminated.", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Mutual split detected. Both survive.", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "Lethal node acquired.", face = "shy" },
        intro_killer_2 = { text = "Activation by others is fatal to them.", face = "scared" },
        intro_killer_3 = { text = "Manipulate subjects into activating it.", face = "normal" },
        intro_saver_1 = { text = "Protective node acquired.", face = "shy" },
        intro_saver_2 = { text = "Activation by others is protective to them.", face = "happy" },
        intro_saver_3 = { text = "Convince subjects to activate it.", face = "normal" },
        intro_others_1 = { text = "Communicate with {p1} and {p2}.", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "One possesses a lethal node.", face = "normal" },
        intro_others_3 = { text = "Evaluate credibility.", face = "nerd" },
        lets_see = { text = "Assessing casualties...", face = "normal" },
        result_no_choice = { text = "Inactivity is fatal. You are terminated.", face = "dead" },
        result_chose_died = { text = "Lethal node from {p} selected. Terminated.", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "Protective node from {p} selected. Safe.", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "Democratic elimination protocol active.", face = "shy" },
        intro_common_1 = { text = "Elimination voting will commence.", face = "normal" },
        intro_candidate_fate = { text = "Fate determined by peers...", face = "scared" },
        intro_choose_wise = { text = "Optimize your choice for elimination.", face = "happy" },
        candidate_line_1 = { text = "Idle phase active during tabulation.", face = "normal" },
        candidate_line_2 = { text = "Erratic behavior noted among subjects.", face = "shy" },
        candidate_line_3 = { text = "Visual bias is highly probable.", face = "normal" },
        candidate_line_4 = { text = "Behavioral bias is highly probable.", face = "scared" },
        candidate_line_5 = { text = "Comprehend?", face = "normal" },
        candidate_line_6 = { text = "Verify your standing with peers.", face = "shy" },
        candidate_line_7 = { text = "Observing results.", face = "scared" },
        you_eliminated = { text = "You were eliminated. System functions nominal.", face = "dead" },
        player_eliminated = { text = "Subject {player} was eliminated.", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Subject {player} identified.", requiredKeys = {"player"}, face = "shy" },
        intro_button_experiment = { text = "Initiating the Button Experiment.", face = "normal" },
        intro_tested = { text = "Your survival instincts will be tested.", face = "scared" },
        intro_easy_hard = { text = "Expect varying levels of lethality.", face = "dead" },
        intro_begin = { text = "Commence testing.", face = "happy" },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "Anomaly: {survivor} avoided termination.", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Experiment complete. One subject remains.", face = "shy" },
        survivor_congratulations = { text = "You survived. Acceptable performance.", face = "happy" },
    }
}

return English