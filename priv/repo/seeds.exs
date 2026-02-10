# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TalesLife2.Repo.insert!(%TalesLife2.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TalesLife2.Repo
alias TalesLife2.Content.Question

# Only seed if there are no questions yet
if Repo.aggregate(Question, :count) == 0 do
  now = DateTime.utc_now(:second)

  questions = [
    # ============================================================
    # EARLY LIFE (50 questions)
    # ============================================================

    # Early Life > Childhood Memories (10)
    %{
      prompt_text:
        "What is your earliest memory? Describe what you remember seeing, hearing, or feeling.",
      era: "early_life",
      category: "childhood",
      position: 1,
      interviewing_tip:
        "Give them time to think. Earliest memories are often fragments — encourage them to share even small details."
    },
    %{
      prompt_text:
        "What did the home you grew up in look like? Can you walk me through it room by room?",
      era: "early_life",
      category: "childhood",
      position: 2,
      interviewing_tip:
        "Physical details often unlock deeper memories. Ask follow-up questions about specific rooms."
    },
    %{
      prompt_text:
        "What was your neighborhood like when you were a child? Who were the characters that lived nearby?",
      era: "early_life",
      category: "childhood",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What games did you play as a child? What did you do for fun on a typical day?",
      era: "early_life",
      category: "childhood",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Did you have a favorite toy, book, or object as a child? What made it special?",
      era: "early_life",
      category: "childhood",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was bedtime like in your house? Were there any rituals or routines?",
      era: "early_life",
      category: "childhood",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the funniest thing that happened to you as a child?",
      era: "early_life",
      category: "childhood",
      position: 7,
      interviewing_tip:
        "Humor is a great way to ease into deeper conversation. Laugh along with them."
    },
    %{
      prompt_text:
        "Was there a place you loved to go as a child — a hiding spot, a park, a relative's house?",
      era: "early_life",
      category: "childhood",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What did you want to be when you grew up? Did that dream change over time?",
      era: "early_life",
      category: "childhood",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What was something you were afraid of as a child? How did you handle that fear?",
      era: "early_life",
      category: "childhood",
      position: 10,
      interviewing_tip: "Be gentle — childhood fears can connect to deeper experiences."
    },

    # Early Life > Family (10)
    %{
      prompt_text: "Tell me about your mother. What kind of person was she?",
      era: "early_life",
      category: "family",
      position: 1,
      interviewing_tip:
        "Let them describe in their own way. Don't assume the relationship was positive or negative."
    },
    %{
      prompt_text: "Tell me about your father. What do you remember most about him?",
      era: "early_life",
      category: "family",
      position: 2,
      interviewing_tip:
        "Some people may not have known their father. Be prepared to adapt the question."
    },
    %{
      prompt_text:
        "Did you have brothers or sisters? What was your relationship like growing up?",
      era: "early_life",
      category: "family",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Were there grandparents, aunts, uncles, or other relatives who played an important role in your childhood?",
      era: "early_life",
      category: "family",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What were mealtimes like in your family? Was there a favorite family meal?",
      era: "early_life",
      category: "family",
      position: 5,
      interviewing_tip:
        "Food memories are powerful connectors. Ask about specific dishes or who cooked."
    },
    %{
      prompt_text: "How did your family celebrate holidays or special occasions?",
      era: "early_life",
      category: "family",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What values or lessons did your parents try to teach you?",
      era: "early_life",
      category: "family",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a family story that was told over and over? What was it?",
      era: "early_life",
      category: "family",
      position: 8,
      interviewing_tip:
        "Family legends reveal what a family values. Ask who usually told the story."
    },
    %{
      prompt_text: "Did your family face any hardships when you were young? How did they cope?",
      era: "early_life",
      category: "family",
      position: 9,
      interviewing_tip:
        "Be sensitive. Let them share at their own pace and don't push for details they're not ready to give."
    },
    %{
      prompt_text:
        "What is something about your family that you didn't understand as a child but understand now?",
      era: "early_life",
      category: "family",
      position: 10,
      interviewing_tip: nil
    },

    # Early Life > School (10)
    %{
      prompt_text: "What do you remember about your first day of school?",
      era: "early_life",
      category: "school",
      position: 1,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Who was your favorite teacher? What made them special?",
      era: "early_life",
      category: "school",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What subjects did you enjoy in school? Were there any you struggled with?",
      era: "early_life",
      category: "school",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Did you have a best friend growing up? How did you meet, and what did you do together?",
      era: "early_life",
      category: "school",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Were you ever bullied, or did you ever witness bullying? How did it affect you?",
      era: "early_life",
      category: "school",
      position: 5,
      interviewing_tip: "This can be a sensitive topic. Follow their lead on how deep to go."
    },
    %{
      prompt_text: "What extracurricular activities or hobbies did you have as a young person?",
      era: "early_life",
      category: "school",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a moment in school that changed how you saw yourself or the world?",
      era: "early_life",
      category: "school",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the social scene like at your school? Where did you fit in?",
      era: "early_life",
      category: "school",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Did you get into any trouble at school? What happened?",
      era: "early_life",
      category: "school",
      position: 9,
      interviewing_tip:
        "A lighthearted question that often produces great stories. Enjoy the telling."
    },
    %{
      prompt_text: "How did your education shape who you became later in life?",
      era: "early_life",
      category: "school",
      position: 10,
      interviewing_tip: nil
    },

    # Early Life > First Experiences (10)
    %{
      prompt_text: "What was the first trip or vacation you remember taking? Where did you go?",
      era: "early_life",
      category: "first_experiences",
      position: 1,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Do you remember your first crush or first romantic feelings? What was that like?",
      era: "early_life",
      category: "first_experiences",
      position: 2,
      interviewing_tip: "Keep it light. This can be a sweet, nostalgic topic."
    },
    %{
      prompt_text: "What was the first job or responsibility you had? How old were you?",
      era: "early_life",
      category: "first_experiences",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Was there a book, movie, or song that deeply affected you when you were young?",
      era: "early_life",
      category: "first_experiences",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "When was the first time you felt truly independent? What happened?",
      era: "early_life",
      category: "first_experiences",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the first big decision you made on your own?",
      era: "early_life",
      category: "first_experiences",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Did you experience the loss of someone close to you at a young age? How did you process that?",
      era: "early_life",
      category: "first_experiences",
      position: 7,
      interviewing_tip:
        "Be very gentle. Give space for silence. It's okay if they choose to skip this one."
    },
    %{
      prompt_text: "What was the first time you traveled away from home on your own?",
      era: "early_life",
      category: "first_experiences",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Was there a moment in your youth when you realized the world was bigger than you thought?",
      era: "early_life",
      category: "first_experiences",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What is something from your early life that you wish you could experience one more time?",
      era: "early_life",
      category: "first_experiences",
      position: 10,
      interviewing_tip:
        "A beautiful closing question for this era. Let them linger in the memory."
    },

    # Early Life > Growing Up (10)
    %{
      prompt_text:
        "What was happening in the world when you were growing up? How did current events affect your family?",
      era: "early_life",
      category: "growing_up",
      position: 1,
      interviewing_tip:
        "This provides historical context. Ask what they remember hearing on the news or from adults."
    },
    %{
      prompt_text:
        "What kind of music did you listen to growing up? Did you have a favorite artist or band?",
      era: "early_life",
      category: "growing_up",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How did your family's financial situation affect your childhood?",
      era: "early_life",
      category: "growing_up",
      position: 3,
      interviewing_tip:
        "Be sensitive. Some people grew up in poverty and may feel shame. Normalize their experience."
    },
    %{
      prompt_text: "What role did religion or spirituality play in your upbringing?",
      era: "early_life",
      category: "growing_up",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Were there any cultural traditions or customs that were important in your household?",
      era: "early_life",
      category: "growing_up",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What did you learn about right and wrong as a child? Who taught you?",
      era: "early_life",
      category: "growing_up",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the hardest part about being young?",
      era: "early_life",
      category: "growing_up",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a moment when you felt like you stopped being a child?",
      era: "early_life",
      category: "growing_up",
      position: 8,
      interviewing_tip: "This can surface powerful stories. Give them space to reflect."
    },
    %{
      prompt_text: "What did you take with you from your childhood that you still carry today?",
      era: "early_life",
      category: "growing_up",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "If you could give advice to your younger self, what would you say?",
      era: "early_life",
      category: "growing_up",
      position: 10,
      interviewing_tip: nil
    },

    # ============================================================
    # MID LIFE (50 questions)
    # ============================================================

    # Mid Life > Career (10)
    %{
      prompt_text:
        "How did you end up in your career or line of work? Was it planned or did you fall into it?",
      era: "mid_life",
      category: "career",
      position: 1,
      interviewing_tip: "Many people's careers took unexpected turns. Follow the surprises."
    },
    %{
      prompt_text:
        "What was the job or role you enjoyed most in your life? What made it fulfilling?",
      era: "mid_life",
      category: "career",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Was there a mentor or colleague who had a significant impact on your professional life?",
      era: "mid_life",
      category: "career",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was your proudest professional accomplishment?",
      era: "mid_life",
      category: "career",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Did you ever face a major setback at work? How did you recover?",
      era: "mid_life",
      category: "career",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How did your work affect your personal life and relationships?",
      era: "mid_life",
      category: "career",
      position: 6,
      interviewing_tip: "Work-life balance stories often reveal core values."
    },
    %{
      prompt_text: "Was there a career path you wish you had taken? What held you back?",
      era: "mid_life",
      category: "career",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What skills or lessons from your working life do you value most?",
      era: "mid_life",
      category: "career",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Did you ever take a big professional risk? What happened?",
      era: "mid_life",
      category: "career",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How did you feel about retirement, or the end of your working years?",
      era: "mid_life",
      category: "career",
      position: 10,
      interviewing_tip: "Not everyone has retired. Adapt this question to their situation."
    },

    # Mid Life > Love and Relationships (10)
    %{
      prompt_text: "How did you meet your partner or spouse? What attracted you to them?",
      era: "mid_life",
      category: "love",
      position: 1,
      interviewing_tip:
        "Not everyone has had a partner. Be ready to reframe: 'Tell me about your most important relationship.'"
    },
    %{
      prompt_text: "What was your wedding day like, or a moment when you committed to someone?",
      era: "mid_life",
      category: "love",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What have been the keys to maintaining a long relationship? What did you learn about love?",
      era: "mid_life",
      category: "love",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is the most romantic or meaningful gesture someone has made for you?",
      era: "mid_life",
      category: "love",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Have you experienced heartbreak? How did it shape you?",
      era: "mid_life",
      category: "love",
      position: 5,
      interviewing_tip: "Give space for this. Heartbreak stories are deeply personal."
    },
    %{
      prompt_text: "What is something your partner taught you about yourself?",
      era: "mid_life",
      category: "love",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Who are the friends that have been most important to you in your adult life?",
      era: "mid_life",
      category: "love",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How has your understanding of love changed over the years?",
      era: "mid_life",
      category: "love",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a relationship you lost that you still think about?",
      era: "mid_life",
      category: "love",
      position: 9,
      interviewing_tip:
        "Tread gently. This could be a deceased spouse, a lost friendship, or an estranged family member."
    },
    %{
      prompt_text: "What does home mean to you? Where have you felt most at home?",
      era: "mid_life",
      category: "love",
      position: 10,
      interviewing_tip: nil
    },

    # Mid Life > Parenting (10)
    %{
      prompt_text:
        "What was it like becoming a parent for the first time? How did it change you?",
      era: "mid_life",
      category: "parenting",
      position: 1,
      interviewing_tip:
        "Not everyone is a parent. If they aren't, ask about nurturing roles — mentoring, caregiving, teaching."
    },
    %{
      prompt_text:
        "What kind of parent did you want to be? How did reality compare to the ideal?",
      era: "mid_life",
      category: "parenting",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the most joyful moment you experienced as a parent?",
      era: "mid_life",
      category: "parenting",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What was the hardest part of raising children?",
      era: "mid_life",
      category: "parenting",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How did you handle discipline and setting boundaries?",
      era: "mid_life",
      category: "parenting",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Is there a parenting moment you wish you could do over?",
      era: "mid_life",
      category: "parenting",
      position: 6,
      interviewing_tip:
        "Parenting regrets can be emotional. Acknowledge their vulnerability in sharing."
    },
    %{
      prompt_text: "What traditions did you create or continue for your own family?",
      era: "mid_life",
      category: "parenting",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How did you balance your own needs with the needs of your family?",
      era: "mid_life",
      category: "parenting",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What do you hope your children or those you've mentored learned from you?",
      era: "mid_life",
      category: "parenting",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How has your relationship with your children changed over the years?",
      era: "mid_life",
      category: "parenting",
      position: 10,
      interviewing_tip: nil
    },

    # Mid Life > Challenges (10)
    %{
      prompt_text:
        "What was the most difficult period of your adult life? How did you get through it?",
      era: "mid_life",
      category: "challenges",
      position: 1,
      interviewing_tip: "This is a big question. Be patient and let them choose what to share."
    },
    %{
      prompt_text:
        "Have you ever faced a serious health challenge? How did it change your perspective?",
      era: "mid_life",
      category: "challenges",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a time when you had to start over? What happened?",
      era: "mid_life",
      category: "challenges",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How have you dealt with loss and grief in your life?",
      era: "mid_life",
      category: "challenges",
      position: 4,
      interviewing_tip: "Allow silence. Grief stories need breathing room."
    },
    %{
      prompt_text:
        "Was there a time you had to stand up for something you believed in, even when it was hard?",
      era: "mid_life",
      category: "challenges",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Have you ever had to forgive someone for something significant? What was that process like?",
      era: "mid_life",
      category: "challenges",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is a mistake you made that ended up teaching you something valuable?",
      era: "mid_life",
      category: "challenges",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Was there a time when you felt truly lost or uncertain about your life's direction?",
      era: "mid_life",
      category: "challenges",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "How did you find strength during your toughest moments? Was there someone or something that helped?",
      era: "mid_life",
      category: "challenges",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Looking back, is there a challenge that you're actually grateful for? Why?",
      era: "mid_life",
      category: "challenges",
      position: 10,
      interviewing_tip:
        "This reframes hardship as growth. It can be a powerful moment in the interview."
    },

    # Mid Life > Turning Points (10)
    %{
      prompt_text: "What would you say are the major turning points of your life?",
      era: "mid_life",
      category: "turning_points",
      position: 1,
      interviewing_tip:
        "This is a big-picture question. Let them identify the moments that matter most to them."
    },
    %{
      prompt_text: "Was there a single decision that changed the course of your life?",
      era: "mid_life",
      category: "turning_points",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Did you ever move to a new place that fundamentally changed your life?",
      era: "mid_life",
      category: "turning_points",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Was there a moment when your beliefs or worldview shifted significantly?",
      era: "mid_life",
      category: "turning_points",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What historical event had the biggest impact on your life?",
      era: "mid_life",
      category: "turning_points",
      position: 5,
      interviewing_tip: "This connects personal narrative to broader history. Great for context."
    },
    %{
      prompt_text: "Was there a person who entered your life and changed everything?",
      era: "mid_life",
      category: "turning_points",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Did you ever have an experience that completely surprised you and changed your path?",
      era: "mid_life",
      category: "turning_points",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What is something you believed strongly in your 20s or 30s that you no longer believe?",
      era: "mid_life",
      category: "turning_points",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Was there a moment when you realized you had become the person you are today?",
      era: "mid_life",
      category: "turning_points",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "If your life were a book, what would you title this middle chapter?",
      era: "mid_life",
      category: "turning_points",
      position: 10,
      interviewing_tip: "A creative question that invites reflection. Give them time to think."
    },

    # ============================================================
    # LATER LIFE (50 questions)
    # ============================================================

    # Later Life > Wisdom (10)
    %{
      prompt_text: "What is the most important lesson life has taught you?",
      era: "later_life",
      category: "wisdom",
      position: 1,
      interviewing_tip: "A foundational question for this era. Let them take their time."
    },
    %{
      prompt_text: "What do you know now that you wish you had known at 25?",
      era: "later_life",
      category: "wisdom",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What has life taught you about happiness? What truly makes you happy?",
      era: "later_life",
      category: "wisdom",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How has your definition of success changed over the course of your life?",
      era: "later_life",
      category: "wisdom",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What do you think is the secret to a good life?",
      era: "later_life",
      category: "wisdom",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What has getting older taught you that younger people might not understand yet?",
      era: "later_life",
      category: "wisdom",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How have your priorities shifted as you've aged?",
      era: "later_life",
      category: "wisdom",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is something you've come to appreciate more with time?",
      era: "later_life",
      category: "wisdom",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What is a piece of wisdom you received from someone else that has stayed with you?",
      era: "later_life",
      category: "wisdom",
      position: 9,
      interviewing_tip: "Ask who said it and when. The context often enriches the wisdom."
    },
    %{
      prompt_text:
        "If you could teach the world one thing from your experience, what would it be?",
      era: "later_life",
      category: "wisdom",
      position: 10,
      interviewing_tip: nil
    },

    # Later Life > Reflections (10)
    %{
      prompt_text: "When you look back on your life, what are you most proud of?",
      era: "later_life",
      category: "reflections",
      position: 1,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Is there anything you regret? Is there something you wish you had done differently?",
      era: "later_life",
      category: "reflections",
      position: 2,
      interviewing_tip: "Handle with care. Regret can be painful. Acknowledge their honesty."
    },
    %{
      prompt_text: "What are you most grateful for in your life?",
      era: "later_life",
      category: "reflections",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How have you changed as a person from who you were in your youth?",
      era: "later_life",
      category: "reflections",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is a memory that always makes you smile?",
      era: "later_life",
      category: "reflections",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Is there a moment in your life you would relive if you could?",
      era: "later_life",
      category: "reflections",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What has been the most unexpected part of your life journey?",
      era: "later_life",
      category: "reflections",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How has your relationship with time changed as you've gotten older?",
      era: "later_life",
      category: "reflections",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What do you think has been misunderstood about your generation?",
      era: "later_life",
      category: "reflections",
      position: 9,
      interviewing_tip: "This can spark passionate responses. Enjoy the energy."
    },
    %{
      prompt_text:
        "If you could have a conversation with anyone from your past, who would it be and what would you say?",
      era: "later_life",
      category: "reflections",
      position: 10,
      interviewing_tip: nil
    },

    # Later Life > Legacy (10)
    %{
      prompt_text: "What do you want your family to remember about you?",
      era: "later_life",
      category: "legacy",
      position: 1,
      interviewing_tip: "This is a deeply personal question. Give it the weight it deserves."
    },
    %{
      prompt_text: "Is there a story from your life that you want to make sure gets passed down?",
      era: "later_life",
      category: "legacy",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What traditions or values do you hope will continue in your family?",
      era: "later_life",
      category: "legacy",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "Have you made peace with the life you've lived? What does that peace look like?",
      era: "later_life",
      category: "legacy",
      position: 4,
      interviewing_tip: "A profound question. Some may not have found peace, and that's okay too."
    },
    %{
      prompt_text: "What do you think is your greatest contribution to the people around you?",
      era: "later_life",
      category: "legacy",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "If you could leave a letter for future generations of your family, what would it say?",
      era: "later_life",
      category: "legacy",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What possessions or keepsakes would you want to pass on, and why are they meaningful?",
      era: "later_life",
      category: "legacy",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How would you like to be remembered by friends and community?",
      era: "later_life",
      category: "legacy",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is the most important thing you've built, created, or contributed to?",
      era: "later_life",
      category: "legacy",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What gives your life meaning today?",
      era: "later_life",
      category: "legacy",
      position: 10,
      interviewing_tip: nil
    },

    # Later Life > Advice (10)
    %{
      prompt_text: "What advice would you give to someone just starting out in adulthood?",
      era: "later_life",
      category: "advice",
      position: 1,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What advice would you give about marriage or committed relationships?",
      era: "later_life",
      category: "advice",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What advice would you give to a new parent?",
      era: "later_life",
      category: "advice",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What would you tell someone going through a difficult time in their life?",
      era: "later_life",
      category: "advice",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What should people worry less about? What should they pay more attention to?",
      era: "later_life",
      category: "advice",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What do you think is the biggest mistake people make in life?",
      era: "later_life",
      category: "advice",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What would you tell your children or grandchildren about handling money?",
      era: "later_life",
      category: "advice",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What advice would you give about choosing friends and surrounding yourself with good people?",
      era: "later_life",
      category: "advice",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What do you wish someone had told you about aging?",
      era: "later_life",
      category: "advice",
      position: 9,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What is one thing you would tell every person to do before it's too late?",
      era: "later_life",
      category: "advice",
      position: 10,
      interviewing_tip: nil
    },

    # Later Life > What Matters Most (10)
    %{
      prompt_text: "At this point in your life, what matters most to you?",
      era: "later_life",
      category: "what_matters_most",
      position: 1,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What brings you the most joy in your daily life right now?",
      era: "later_life",
      category: "what_matters_most",
      position: 2,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Who are the people that mean the most to you today?",
      era: "later_life",
      category: "what_matters_most",
      position: 3,
      interviewing_tip: nil
    },
    %{
      prompt_text: "Is there something you still want to do or experience?",
      era: "later_life",
      category: "what_matters_most",
      position: 4,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What does a good day look like for you now?",
      era: "later_life",
      category: "what_matters_most",
      position: 5,
      interviewing_tip: nil
    },
    %{
      prompt_text: "How do you stay connected to the people and things you love?",
      era: "later_life",
      category: "what_matters_most",
      position: 6,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What role does faith, spirituality, or philosophy play in your life today?",
      era: "later_life",
      category: "what_matters_most",
      position: 7,
      interviewing_tip: nil
    },
    %{
      prompt_text: "What are you still curious about or eager to learn?",
      era: "later_life",
      category: "what_matters_most",
      position: 8,
      interviewing_tip: nil
    },
    %{
      prompt_text:
        "What would you want to say to the people you love, if you had their full attention?",
      era: "later_life",
      category: "what_matters_most",
      position: 9,
      interviewing_tip:
        "This can be deeply emotional. Be present. This is often the most powerful moment in an interview."
    },
    %{
      prompt_text:
        "Is there anything else you'd like to share — something we haven't covered that feels important to your story?",
      era: "later_life",
      category: "what_matters_most",
      position: 10,
      interviewing_tip:
        "Always end with an open door. Some of the best stories come from this final invitation."
    }
  ]

  # Insert all questions with timestamps
  entries =
    Enum.map(questions, fn q ->
      Map.merge(q, %{inserted_at: now, updated_at: now})
    end)

  {count, _} = Repo.insert_all(Question, entries)
  IO.puts("Seeded #{count} interview questions")
end
