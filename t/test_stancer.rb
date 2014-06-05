#!/usr/bin/ruby

require 'stancer'
require 'minitest/autorun'

describe "When looking at a single motion" do

  describe "when dealing with a single MP" do

    before do
      @stance = Stance.new( 'voter.id:david_cameron', Issue.new('PW-1049'))
    end

    it "can't handle missing motions" do
      ->{ @stance.motion_score('no-such-motion') }.must_raise RuntimeError
    end

    it "should get correct score/max" do
      score = @stance.motion_score('pw-2003-02-26-96')
      score[:score].must_equal 10
      score[:max].must_equal 10
    end

  end

  describe "when dealing with a party" do

    before do
      @stance = Stance.new( 'party.id:sdlp', Issue.new('PW-1049'))
    end

    it "should get correct score/max" do
      score = @stance.motion_score('pw-2003-03-18-117')
      score[:score].must_equal 50
      score[:max].must_equal 150
    end

  end

end

describe "When looking at a whole issue " do

  describe "when dealing with a single MP" do

    before do
      @issue =  Issue.new('PW-1049')
      @stance = Stance.new( 'voter.id:david_cameron', @issue )
    end

    it "count should sum" do
      score = @stance.score
      cnt = 0
      @issue.motion_ids.each do |mid|
        cnt += @stance.motion_score(mid)[:num_votes]
      end
      cnt.must_equal score[:num_votes]
    end

    it "sum should sum" do
      score = @stance.score
      sum = 0
      @issue.motion_ids.each do |mid|
        sum += @stance.motion_score(mid)[:score]
      end
      sum.must_equal score[:score]
    end

    it "max should sum" do
      score = @stance.score
      max = 0
      @issue.motion_ids.each do |mid|
        max += @stance.motion_score(mid)[:max]
      end
      max.must_equal score[:max]
    end


    it "should get correct score/max" do
      score = @stance.score
      score[:score].must_equal 131
      
      # Public Whip thinks max should be 132
      # They count absences differenly
      score[:max].must_equal 140
    end

  end

  describe "when dealing with a party" do

    before do
      @stance = Stance.new( 'party.id:sdlp', Issue.new('PW-1049'))
    end

    it "should get correct score/max" do
      score = @stance.score
      score[:score].must_equal 106
      score[:max].must_equal 420
    end

  end

end





