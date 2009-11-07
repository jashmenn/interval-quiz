$:.unshift(File.dirname(__FILE__) + "/../../interval/lib")
require "rubygems"
require "interval"
require "highline/import"
require "madeleine"
require "pp"

class Quiz
  # Here is the list of intervals by semitone. This is just here for reference:
  #
  # 0	Perfect Unison (P1)	Diminished second (dim2)
  # 1	Minor second (m2)	Augmented unison (aug1)
  # 2	Major second (M2)	Diminished third (dim3)
  # 3	Minor third (m3)	Augmented second (aug2)
  # 4	Major third (M3)	Diminished fourth (dim4)
  # 5	Perfect fourth (P4)	Augmented third (aug3)
  # 6	Tritone	Augmented fourth (aug4) Diminished fifth (dim5)
  # 7	Perfect fifth (P5)	Diminished sixth (dim6)
  # 8	Minor sixth (m6)	Augmented fifth (aug5)
  # 9	Major sixth (M6)	Diminished seventh (dim7)
  # 10	Minor seventh (m7)	Augmented sixth (aug6)
  # 11	Major seventh (M7)	Diminished octave (dim8)
  # 12	Perfect octave (P8)	Augmented seventh (aug7)

  attr_accessor :intervals  # which intervals we will quiz on
  attr_accessor :abovebelow # array of ["", "-"] if "-" is present, then we are quizzing on intervals below
  attr_accessor :asked
  attr_accessor :correct

  def initialize
    self.asked = 0
    self.correct = 0
  end

  def run!
    loop do

      pitch = Interval::Pitch.random 
      ab = self.abovebelow.rand
      ab_eng = ab == "-" ? "below" : "above"
      interval = Interval::Interval.from_string(ab + self.intervals.rand)

      begin
        answer = ask("what is a #{interval.to_long_name.downcase} #{ab_eng} #{pitch.to_s} #{score_str}? ")
        self.asked = self.asked + 1
      rescue EOFError 
        puts "goodbye"
        exit
      end

      real_answer = pitch + interval

      if answer.downcase == real_answer.to_short_name.downcase
        puts "correct!"
        self.correct = correct + 1
      else
        puts "wrong. the answer is #{real_answer.to_short_name}"
      end
    end
  end

  def score_str
    if asked && asked > 0
      "#{correct}/#{asked} (%d%%)" % [(correct.to_f / asked.to_f) * 100]
    else
      ""
    end
  end

end

class IntervalQuiz

  def run!
      say("Here are the intervals:")
      intervals =<<-EOF
unison  p1        a1 
second  m2 M2  d2 a2
third   m3 M3  d3 a3 
fourth  p4     d4 a4
fifth   d5 p5  d4 a5
sixth   m6 M6  d6 a6
seventh m7 M7  d7 a7
octave  p8     d8
EOF
      say(intervals)

      picked = ask("enter the intervals you want (or a blank line to quit):", lambda { |ans| ans} ) do |q|
        q.gather = ""
      end

      pp picked

      abovebelow = []
      choose do |menu|
        menu.prompt = "do you want to be quizzed on intervals above, below, or both?  "
        menu.choice(:above) { abovebelow = [""] }
        menu.choice(:below) { abovebelow = ["-"] }
        menu.choice(:both)  { abovebelow = ["", "-"] }
      end

      q = Quiz.new
      q.abovebelow = abovebelow
      q.intervals = picked

      q.run!
  end

end

if $0 == __FILE__
  quiz = IntervalQuiz.new
  quiz.run!
end
