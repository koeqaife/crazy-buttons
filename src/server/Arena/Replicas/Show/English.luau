--!strict
--!optimize 2

local Format = require(script.Parent.Parent.Format)
type DictTemplate = {[string]: {[string]: Format.Template}}

local English: DictTemplate = {
    --| MISC |--
    misc = {
        error_occurred = { text = "Whoops! Technical difficulties!", face = "dead" },
        purchase_not_processed = { text = "Purchase secured! We'll deliver it next time!", face = "nerd" },
        purchase_processed = { text = "Cha-ching! Purchase successful!", face = "nerd" },
        players_left = { text = "Only {count} contestants remaining!", requiredKeys = {"count"}, face = "normal" }
    },

    --| ALIEN EVENT |--
    alien = {
        secret_question = { text = "Ooh, an exclusive interview with the aliens!", face = "shy" },
        question_for_you = { text = "Time for a surprise question!", face = "normal" },
        question_like_aliens = { text = "Are we fans of the little green men?!", face = "alien" },
        oh_no = { text = "Yikes! That's not good!", face = "no_mouth" },
        not_nice = { text = "Wow, no manners at all!", face = "unamused" },
        happy_face = { text = "Big smiles everyone! :D", face = "happy" },
        that_is_cool = { text = "Absolutely incredible!", face = "shy" }
    },

    --| ATTACK DEFEND TRUST EVENT |--
    att_def_trust = {
        chosen_players = { text = "Give it up for {p1} and {p2} in the arena!", requiredKeys = {"p1", "p2"}, face = "att_def_tru_icon" },
        rules_are_simple = { text = "The rules are a piece of cake!", face = "happy" },
        rules = { text = "Attack beats Trust! Defend beats Attack! Trust beats Defend!", face = "nerd" },
        loser_eliminate = { text = "The loser goes home... forever!", face = "dead" },
        choose_your_move = { text = "Lock in your answers now!", face = "normal" },
        waiting_for_move = { text = "Nerve-wracking wait for {p1} and {p2}...", requiredKeys = {"p1", "p2"}, face = "normal" },
        both_did_not_move = { text = "No action? Double elimination!", face = "dead" },
        you_both_chose = { text = "Unbelievable! You both locked in {btn}!", requiredKeys = {"btn"}, face = "laughing" },
        they_both_chose = { text = "Mind readers! They both chose {btn}!", requiredKeys = {"btn"}, face = "laughing" },
        tie_choose_again = { text = "It's a draw! We go to sudden death!", face = "shy" },
        tie_they_choose_again = { text = "It's a tie! Let's rerun that!", face = "shy" },
        att_def = { text = "Denied! They blocked your strike!", face = "dead" },
        def_att = { text = "What a block! You survived the hit!", face = "happy" },
        att_trust = { text = "Betrayal! They trusted and paid the price!", face = "happy" },
        trust_att = { text = "Ouch! You trusted the wrong person!", face = "dead" },
        def_trust = { text = "You blocked nothing and tripped! Hilarious!", face = "dead" },
        trust_def = { text = "They looked silly blocking the wind!", face = "happy" },
        won_against = { text = "And {won} takes the glorious victory over {lost}!", requiredKeys = {"won", "lost"}, face = "happy" }
    },

    --| CLICK EVENT |--
    click = {
        reaction_test_for_dead = { text = "Time for a reflex challenge!", face = "click_button_icon" },
        reaction_test = { text = "Read the screen and press the button if told!", face = "click_button_icon" },
        not_much_time = { text = "You only have two seconds to react!", face = "no_mouth" },
        be_ready = { text = "Get ready!", face = "shy" },
        seconds_3 = { text = "3...", face = { text = "3"} },
        seconds_2 = { text = "2...", face = { text = "2"} },
        seconds_1 = { text = "1...", face = { text = "1"} },
        button_says_truth = { text = "BUTTON SAYS TRUTH!", face = "click_button_icon" },
        button_says_lie = { text = "BUTTON SAYS LIE!", face = "click_button_icon" },
        you_had_to_click = { text = "Too slow! You should've clicked!", face = "dead" },
        you_had_to_not_click = { text = "Trigger happy! You shouldn't have clicked!", face = "dead" },
        you_survived = { text = "You survived the round!", face = "happy" },
    },

    --| CLICK FIRST EVENT |--
    click_first = {
        they_have_to_click = { text = "It's a speed round! Get ready to click!", face = "click_button_icon" },
        last_num_eliminate = { text = "The last {num} go home empty-handed!", requiredKeys = {"num"}, face = "dead" },
        click_faster = { text = "Click faster than the competition!", face = "scared" },
        you_have_to_click = { text = "Smash that button right now!", face = "click_button_icon" },
        you_did_not_click = { text = "You totally missed it!", face = "angry" },
        you_clicked_too_slow = { text = "Way too slow for this show!", face = "scared" },
        you_survived = { text = "You are safe for now!", face = "happy" },
        you_are_eliminated = { text = "You have been eliminated!", face = "dead" },
        wait_for_others = { text = "Waiting for the rest of the players...", face = "dead" },
        wait_for_green = { text = "Wait for the magic green light!", face = { text = "..." } }
    },

    --| COLOR EVENT |--
    color = {
        for_dead_remember = { text = "Let's see who has the best memory!", icon = "color_event_icon" },
        for_dead_start = { text = "They need to remember a special color!", face = "color_event_icon" },
        you_remember_color = { text = "Do you remember your favorite color?", face = "color_event_icon" },
        lets_check = { text = "Time to test that brain of yours!", face = "shy" },
        did_not_choose = { text = "Oh no, you didn't even pick one!", face = "laughing" },
        so_lucky = { text = "What a lucky person!", face = "angry" },
        which_one_you_chose = { text = "So, what was your choice?", face = "nerd" },
        wrong_color = { text = "Bzzzt! Wrong answer!", face = "dead" },
        correct_color = { text = "Ding ding! Perfect memory!", face = "happy" },
        good_job = { text = "Fantastic job!", face = "shy" },
        about_to_show_colors = { text = "Look at these fabulous colors!", face = "color_event_icon" },
        remember_color = { text = "Pick one and burn it into your mind!", face = "normal" },
        choose = { text = "Which one is your favorite?", face = "nerd" },
        red = { text = "Red! Bold and fiery!", face = "happy" },
        blue = { text = "Blue! Cool as the ocean!", face = "happy" },
        pink = { text = "Pink! Sweet like cotton candy!", face = "happy" },
        yellow = { text = "Yellow! Bright as the sun!", face = "happy" },
        green = { text = "Green! Fresh and natural!", face = "happy" },
        nothing = { text = "Nothing? We're assigning you {color}!", requiredKeys = {"color"}, face = "laughing" },
    },

    --| COMBO EVENT |--
    combo = {
        for_dead = { text = "Copycat round! The weakest links go home!", face = "combo_event_icon" },
        repeat_after_me = { text = "Repeat the sequence perfectly!", face = "combo_event_icon" },
        players_to_eliminate = { text = "Most mistakes gets eliminated!", face = "dead" },
        lets_start = { text = "Let the games begin!", face = "shy" },
        my_turn = { text = "Watch the master at work!", face = "normal" },
        your_turn = { text = "Your turn!", face = "nerd" },
        clicks_left = { text = "{num} clicks to go!", face = "nerd", requiredKeys = {"num"} },
        wait = { text = "Waiting on the slowpokes!", face = "normal" },
        mistakes_count = { text = "You made {num} mistakes...", requiredKeys = {"num"}, face = "laughing" },
        lets_see = { text = "Let's check the final scoreboard!", face = "scared" },
        you_eliminated = { text = "You're the weakest link! Goodbye!", face = "dead" },
        you_survived = { text = "You survive to play another round!", face = "happy" },
    },

    --| DUEL EVENT |--
    duel = {
        to_play = { text = "A massive face-off between {p1} and {p2}!", face = "click_button_icon", requiredKeys = {"p1", "p2"} },
        first_one_survives = { text = "Fastest finger wins it all!", face = "normal" },
        you_did_not_click = { text = "You didn't even try!", face = "angry" },
        you_are_eliminated = { text = "You've been eliminated!", face = "dead" },
        good_job = { text = "Incredible reflexes!", face = "shy" },
        you_were_fast_enough = { text = "Lightning fast! You win!", face = "happy" },
        you_are_slow = { text = "Too slow! Better luck next time!", face = "laughing" },
        won = { text = "{player} takes the grand victory!", face = "happy", requiredKeys = {"player"} }
    },

    --| EVEN ODD EVENT |--
    even_odd = {
        intro_dead = { text = "It's the ultimate Push or Pass challenge!", face = "even_odd_event_icon" },
        intro_alive = { text = "To push, or not to push? You decide!", face = "even_odd_event_icon" },
        intro_counting = { text = "I'll tally up everyone's decisions!", face = "nerd" },
        intro_odd = { text = "If the total is odd, pushers go home!", face = "even_odd_event_icon" },
        intro_even = { text = "If it's even, the passers are eliminated!", face = "even_odd_event_icon" },
        remember_to_talk = { text = "Talk it out and strategize!", face = "shy" },
        time_to_count = { text = "Time to count the votes!", face = "scared" },
        player_clicked = { text = "{player} pushed the button!", requiredKeys = {"player"}, face = "normal" },
        count_even = { text = "The final result is EVEN!", face = "normal" },
        count_odd = { text = "The final result is ODD!", face = "normal" },
        you_survived = { text = "You are safe! Phew!", face = "happy" },
        you_are_eliminated = { text = "You're outta here!", face = "dead" }
    },

    --| GOD BUTTON EVENT |--
    god_btn = {
        intro_dead = { text = "Mega button hunt starts right now!", face = "laughing" },
        intro_ready = { text = "Are your eyes ready?", face = "happy" },
        intro_100_buttons = { text = "There are 100 buttons on the board!", face = "scared" },
        intro_first_rewarded = { text = "First to find the golden one gets a prize!", face = "shy" },
        good_luck = { text = "Ready, set, GO!", face = "laughing" },
        you_found_god_btn = { text = "You found the magic button!", face = "happy" },
        someone_found_god_btn = { text = "{player} found the button!", requiredKeys = {"player"}, face = "scared" },
        no_one_found_god_btn = { text = "Nobody found it? Wow...", face = "laughing" }
    },

    --| HANDOUT EVENT |--
    handout = {
        intro_dead = { text = "It's time for a prize giveaway!", face = "laughing" },
        intro_alive_part1 = { text = "One very lucky contestant gets a gift!", face = "happy" },
        intro_alive_part2 = { text = "The tension is building.......", face = "scared" },
        dead_who_got = { text = "{player} won the prize!", requiredKeys = {"player"}, face = "laughing" },
        you_got_tool_part1 = { text = "You!", face = "happy" },
        you_got_tool_part2 = { text = "Click that shiny new button!", face = "shy" },
        you_got_tool_part3 = { text = "And pick your favorite player!", face = "no_mouth" },
        you_got_tool_part4 = { text = "Get ready for a confetti explosion!", face = "laughing" },
        someone_got_tool_part1 = { text = "{player}!", requiredKeys = {"player"}, face = "normal" },
        someone_got_tool_part2 = { text = "They just got an awesome gift!", face = "happy" },
        someone_got_tool_part3 = { text = "Isn't that exciting?!", face = "shy" },
        someone_got_tool_part4 = { text = "Best of luck to everyone!", face = "scared" }
    },

    --| LINKED EVENT |--
    linked = {
        intro_part1 = { text = "Time for the Buddy System!", face = "scared" },
        intro_part2 = { text = "If one goes down, they both go down!", face = "dead" },
        intro_part3 = { text = "Spinning the wheel of fate...", face = "shy" },
        first_player_is = { text = "Our first buddy is...", face = "normal" },
        second_player_is = { text = "And their partner is...", face = "normal" },
        player = { text = "{player}!", requiredKeys = {"player"} },
    },

    --| MATH EVENT |--
    math = {
        dead_who_quiz = { text = "Our brainiac {player} takes the stage!", requiredKeys = {"player"}, face = "nerd" },
        intro_self_q1 = { text = "Are you a math genius?", face = "nerd" },
        intro_self_q2 = { text = "Everyone's lives are in your hands!", face = "scared" },
        intro_others_q1 = { text = "Do you think {player} is smart enough?", requiredKeys = {"player"}, face = "nerd" },
        intro_others_q2 = { text = "Time to find out!", face = "shy" },
        calculate_this = { text = "Solve this equation:\n{exp}", requiredKeys = {"exp"}, face = "nerd" },
        is_player_smart = { text = "Will {player} manage to solve:\n{exp}?", requiredKeys = {"player","exp"}, face = "nerd" },
        you_answer_right = { text = "Spot on! Great math skills!", face = "happy" },
        you_answer_wrong = { text = "Oh no, totally wrong!", face = "scared" },
        you_not_believed = { text = "No one believed in you anyway...", face = "dead" },
        you_had_to_answer = { text = "You didn't even guess!", face = "dead" },
        you_wrong_lucky = { text = "Wrong, but you got super lucky!", face = "happy" },
        you_wrong = { text = "Bzzzt! Wrong answer!", face = "dead" },
        you_right = { text = "Ding ding! Correct!", face = "happy" },
    },

    --| MAZE EVENT |--
    maze = {
        intro_part1 = { text = "The Labyrinth is officially open!", face = "normal" },
        intro_part2 = { text = "There are 6 mystery buttons inside!", face = "normal" },
        intro_part3 = { text = "One eliminates, one gives a grand prize!", face = "scared" },
        intro_part4 = { text = "Get running and good luck!", face = "happy" },
        somebody_awarded = { text = "Someone just got rich!", face = "happy" },
        no_one_awarded = { text = "Nobody won the prize today!", face = "no_mouth" },
    },

    --| REVIVE EVENT |--
    revive = {
        intro_random = { text = "It's time for a random second chance!", face = "shy" },
        player_revived = { text = "{player} is back in the game!", requiredKeys = {"player"}, face = "happy" },
        intro_vote_common = { text = "Audience vote for a second chance!", face = "shy" },
        intro_vote_candidate = { text = "Will the others vote for you?", face = "shy" },
        intro_dead_not_you = { text = "Too bad it's not you...", face = "no_mouth" },
        intro_choose_wise = { text = "Vote wisely on who comes back!", face = "nerd" },
        you_are_revived = { text = "You have been revived!", face = "happy" },
    },

    --| SACRIFICE EVENT |--
    sacrifice = {
        dead_intro = { text = "Hero time for {p1} and {p2}!", requiredKeys = {"p1", "p2"}, face = "scared" },
        chosen_you_1 = { text = "You're in the spotlight...", face = "scared" },
        chosen_you_2 = { text = "We need a hero to take the fall for you!", face = "scared" },
        chosen_others_1 = { text = "{p1} and {p2} are in grave danger!", requiredKeys = {"p1","p2"}, face = "laughing" },
        prompt_sacrifice = { text = "Will you be the ultimate hero for them?", face = "shy" },
        press_to_save = { text = "Smash the button to save them!", face = "shy" },
        choice_cannot_be_undone = { text = "No turning back now!", face = "dead" },
        you_are_eliminated = { text = "You made the ultimate sacrifice!", face = "dead" },
        they_are_eliminated = { text = "They're outta here!", face = "scared" },
        you_are_saved = { text = "You got saved!", face = "happy" },
        you_saved_them = { text = "What a hero! You saved them!", face = "dead" },
        they_were_saved = { text = "{p1} and {p2} are safe and sound!", requiredKeys = {"p1","p2"}, face = "happy" },
    },

    --| SIMON EVENT |--
    simon = {
        intro_dead = { text = "We're playing Simon Says!", face = "nerd" },
        intro_alive_1 = { text = "I am your Simon for today!", face = "shy" },
        intro_alive_2 = { text = "No 'Simon says'? Do the exact opposite!", face = "nerd" },
        round_text = { text = "{text}", face = "normal" },
    },

    --| SPLIT OR STEAL EVENT |--
    split_steal = {
        intro_you_pair = { text = "You are up with {p2} for Split or Steal!", requiredKeys = {"p2"}, face = "scared" },
        intro_others_pair = { text = "{p1} and {p2} step right up to the podium!", requiredKeys = {"p1","p2"}, face = "happy" },
        rule_both_split = { text = "If both split, everyone's happy!", face = "happy" },
        rule_one_steal = { text = "If one steals, the other goes home!", face = "scared" },
        rule_both_steal = { text = "Double steal means double elimination!", face = "laughing" },
        rule_both_steal_others = { text = "If both steal, they both lose!", face = "laughing" },
        choose_wisely = { text = "Lock in your choices!", face = "nerd" },
        waiting_for_players = { text = "The tension is so high right now!", face = "normal" },
        both_steal = { text = "Greedy! Double steal! Both are out!", face = "laughing" },
        stealer_chosen = { text = "{stealer} robbed {victim} blind! {victim} is out!", requiredKeys = {"stealer","victim"}, face = "unamused" },
        both_split = { text = "Beautiful teamwork! Both survive!", face = "happy" },
    },

    --| TWO KNOWS EVENT |--
    two_knows = {
        intro_killer_1 = { text = "You got the Poison Button!", face = "shy" },
        intro_killer_2 = { text = "Whoever clicks it is instantly out!", face = "scared" },
        intro_killer_3 = { text = "Trick the others into clicking it!", face = "normal" },
        intro_saver_1 = { text = "You got the Cure Button!", face = "shy" },
        intro_saver_2 = { text = "Whoever clicks it gets total safety!", face = "happy" },
        intro_saver_3 = { text = "Convince the others to trust you!", face = "normal" },
        intro_others_1 = { text = "Have a chat with {p1} and {p2}!", requiredKeys = {"p1","p2"}, face = "shy" },
        intro_others_2 = { text = "One is lying, one is telling the truth!", face = "normal" },
        intro_others_3 = { text = "Who do you trust more?!", face = "nerd" },
        lets_see = { text = "Let's reveal the results!", face = "normal" },
        result_no_choice = { text = "You ran out of time! You're out!", face = "dead" },
        result_chose_died = { text = "You picked {p}'s poison! You're out!", requiredKeys = {"p"}, face = "dead" },
        result_chose_safe = { text = "You picked {p}'s cure! You are safe!", requiredKeys = {"p"}, face = "happy" },
    },

    --| VOTE EVENT |--
    vote = {
        dead_intro = { text = "It's time for the elimination vote!", face = "shy" },
        intro_common_1 = { text = "The crowd decides who goes home!", face = "normal" },
        intro_candidate_fate = { text = "Your fate is in their hands...", face = "scared" },
        intro_choose_wise = { text = "Vote for your least favorite player!", face = "happy" },
        candidate_line_1 = { text = "Take a break while the votes come in!", face = "normal" },
        candidate_line_2 = { text = "People's choices are totally wild!", face = "shy" },
        candidate_line_3 = { text = "They might vote based on looks alone!", face = "normal" },
        candidate_line_4 = { text = "Or maybe a grudge from last round!", face = "scared" },
        candidate_line_5 = { text = "You know how dramatic this gets!", face = "normal" },
        candidate_line_6 = { text = "Hope you've been making friends!", face = "shy" },
        candidate_line_7 = { text = "Let's read the final votes!", face = "scared" },
        you_eliminated = { text = "The tribe has spoken. You're out!", face = "dead" },
        player_eliminated = { text = "{player} was voted out!", requiredKeys = {"player"}, face = "dead" },
    },

    --| START EVENT |--
    start = {
        intro_hey = { text = "Heeeeeeeere's {player}!", requiredKeys = {"player"}, face = "shy" },
        intro_button_experiment = { text = "Welcome to the grand Button Experiment!", face = "normal" },
        intro_tested = { text = "Get ready for the wildest challenges of your life!", face = "scared" },
        intro_easy_hard = { text = "Some are a breeze, some are deadly!", face = "dead" },
        intro_begin = { text = "Let's get this show on the road!", face = "happy" },
    },

    --| YOU SURVIVED EVENT |--
    you_survived = {
        survivor_made_it = { text = "Give a round of applause for {survivor}!", requiredKeys = {"survivor"}, face = "happy" },
        survivor_one_left = { text = "Look at that, you're the final star shining!", face = "shy" },
        survivor_congratulations = { text = "You are our Grand Champion! Congrats!", face = "happy" },
    }
}

return English