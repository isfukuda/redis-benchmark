#!/usr/bin/env ruby

require 'benchmark'
require 'redis'

def before(key, redis, user_score)
  redis.zrangebyscore(key, user_score-1, user_score+1)
end

def after(key, redis, user)
  rank = redis.zrank(key, user) + rand(-10..10)
  redis.zrange(key, rank-10, rank+10)
end

# r = Redis.new
r = Redis.new(host: "10.0.0.3", port: 6379, db: 0)
iterations = 10_000
my_user = 'user'
my_score = 5

[100, 1_000, 10_000].each do |n|
  r.zadd "sample_#{n}", my_score, my_user 
  (1..n).each do |i|
    r.zadd "sample_#{n}", rand(1..10), i
  end

  range_count = r.zrangebyscore("sample_#{n}", my_score-1, my_score+1).count
  puts "sample_#{n} item count between #{my_score-1}-#{my_score+1}: #{range_count}"
end

Benchmark.bm(13) do |x|
  [100, 1_000, 10_000].each do |n|
    x.report("before_#{n}") do
      iterations.times do
        before("sample_#{n}", r, my_score)
      end
    end
    x.report("after_#{n}") do
      iterations.times do
        after("sample_#{n}", r, my_user)
      end
    end
  end
end

[100, 1_000, 10_000].each do |n|
  r.del "sample_#{n}"
end
