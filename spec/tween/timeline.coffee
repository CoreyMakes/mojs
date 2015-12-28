Timeline = window.mojs.Timeline
Tween    = window.mojs.Tween
tweener  = window.mojs.tweener
Transit  = window.mojs.Transit
h        = mojs.h

describe 'Timeline ->', ->
  beforeEach -> tweener.removeAll()
  it 'should extend Tween', ->
    expect( Timeline.prototype instanceof Tween ).toBe true
    expect( Tween.isPrototypeOf( Timeline ) ).toBe true

  describe 'defaults ->', ->
    it 'should have defaults', ->
      t = new Timeline
      expect(t._defaults.repeat)          .toBe 0
      expect(t._defaults.delay)           .toBe 0
      expect(t._defaults.duration)        .toBe 0
      expect(t._defaults.yoyo)            .toBe false
      expect(t._defaults.easing)          .toBe 'Linear.None'
      expect(t._defaults.onStart)         .toBe null
      expect(t._defaults.onComplete)      .toBe null
      expect(t._defaults.onRepeatStart)   .toBe null
      expect(t._defaults.onRepeatComplete).toBe null
      expect(t._defaults.onFirstUpdate)   .toBe null
      expect(t._defaults.onUpdate)        .toBe null
      expect(t._defaults.onProgress)      .toBe null
      expect(t._defaults.isChained)       .toBe false

  describe '_extendDefaults method ->', ->
    it 'should call super _extendDefaults function', ->
      t = new Timeline
      spyOn Timeline.prototype, '_extendDefaults'
      t._extendDefaults()
      expect(Timeline.prototype._extendDefaults).toHaveBeenCalled()
    it 'should extend defaults by options', ->
      t = new Timeline duration: 200
      expect(t._props.duration).toBe 0

  describe '_vars method ->', ->
    it 'should declare _timelines array', ->
      t = new Timeline
      expect(t.h.isArray(t._timelines)).toBe true
      expect(t._timelines.length).toBe 0
    it 'should call super _vars function', ->
      t = new Timeline
      spyOn Timeline.prototype, '_vars'
      t._vars()
      expect(Timeline.prototype._vars).toHaveBeenCalled()

  describe 'add method ->', ->
    it 'should add timeline',->
      t = new Timeline
      tw = new Tween
      t.add tw
      expect(t._timelines.length).toBe 1
      expect(t._timelines[0])    .toBe tw
    it 'should return self for chaining',->
      t = new Timeline
      obj = t.add new Tween
      expect(obj).toBe t
    it 'should treat a module with timeline object as a timeline',->
      t = new Timeline
      tr = new Transit
      t.add tr
      expect(t._timelines.length).toBe 1
      expect(t._timelines[0] instanceof Timeline).toBe true
      expect(t._timelines[0] is tr.timeline).toBe true
    it 'should work with arrays of tweens',->
      t = new Timeline
      t1 = new Tween duration: 1000
      t2 = new Tween duration: 1500
      tm = new Timeline
      t.add [t1, t2, tm]
      expect(t._timelines.length).toBe 3
      # expect(t._props.repeatTime).toBe 1500
      expect(t._timelines[0] is t1).toBe true
      expect(t._timelines[1] is t2).toBe true
      expect(t._timelines[2] is tm).toBe true
    it 'should work with arguments',->
      tween = new Timeline
      t1 = new Tween duration: 500, delay: 200
      t2 = new Tween duration: 500, delay: 500
      tween.add t1, t2
      # expect(tween._props.repeatTime).toBe 1000
      expect(tween._timelines.length).toBe 2
    it 'should work with mixed arguments',->
      t = new Timeline
      t1 = new Tween duration: 1000
      t2 = new Tween duration: 1500
      t3 = new Tween
      tm = new Timeline
      t.add [t1, t2, tm], t3
      expect(t._timelines.length).toBe 4
      # expect(t._props.repeatTime).toBe 1500
      expect(t._timelines[0] is t1).toBe true
      expect(t._timelines[1] is t2).toBe true
      expect(t._timelines[2] is tm).toBe true
      expect(t._timelines[3] is t3).toBe true
    it 'should calc self duration',->
      t = new Timeline
      t.add new Tween duration: 500, delay: 200
      expect(t._props.time).toBe 700
      t.add new Tween duration: 500, delay: 200, repeat: 1
      expect(t._props.time).toBe 1400
      it 'should work with another tweens',->
        t1 = new Timeline
        t = new Timeline
        t.add new Tween duration: 500, delay: 200
        t.add new Tween duration: 500, delay: 200, repeat: 1
        t1.add t
        expect(t1._props.repeatTime).toBe 1400
  describe '_setProgress method ->', ->
    it 'should call super _setProgress method', ->
      t = new Timeline
      spyOn Tween.prototype, '_setProgress'
      t._setProgress 1, 2
      expect(Tween.prototype._setProgress).toHaveBeenCalledWith 1, 2
    it 'should save previous yoyo value', ->
      t = new Timeline yoyo: true, repeat: 1
      progress = .75; time = 2
      t._setProgress progress - .1, time, true
      t._setProgress progress, time, true
      expect(t._prevYoyo).toBe true

    it 'should call _update method on every timeline forward', ->
      t = new Timeline
      tw1 = new Tween
      tw2 = new Tween
      t.add tw1, tw2
      spyOn tw1, '_update'; spyOn tw2, '_update'
      t._setStartTime()
      progress = .75; time = t._props.startTime + progress*t._props.duration
      t._update time-1
      t._update time
      expect(tw1._update).toHaveBeenCalledWith time, time-1, undefined, 0
      expect(tw2._update).toHaveBeenCalledWith time, time-1, undefined, 0

    it 'should call _update method on every timeline backward', ->
      t = new Timeline
      tw1 = new Tween
      tw2 = new Tween
      t.add tw1, tw2
      spyOn tw1, '_update'; spyOn tw2, '_update'
      t._setStartTime()
      progress = .75; time = t._props.startTime + progress*t._props.duration
      t._update time+1
      t._update time
      expect(tw1._update).toHaveBeenCalledWith time, time+1, undefined, 0
      expect(tw2._update).toHaveBeenCalledWith time, time+1, undefined, 0

    it 'should call _update method on every timeline forward yoyo', ->
      t = new Timeline yoyo: true, isIt: 1
      tw1 = new Tween
      tw2 = new Tween
      t.add tw1, tw2
      spyOn tw1, '_update'; spyOn tw2, '_update'
      t._setStartTime()
      progress = .75; time = t._props.startTime + progress*t._props.duration
      t._update time-1
      t._update time
      expect(tw1._update).toHaveBeenCalledWith time, time-1, undefined, 0
      expect(tw2._update).toHaveBeenCalledWith time, time-1, undefined, 0

    it 'should call _update method on every timeline backward yoyo', ->
      t = new Timeline yoyo: true, isIt: 1
      tw1 = new Tween
      tw2 = new Tween
      t.add tw1, tw2
      spyOn tw1, '_update'; spyOn tw2, '_update'
      t._setStartTime()
      progress = .75; time = t._props.startTime + progress*t._props.duration
      t._update time+1
      t._update time
      expect(tw1._update).toHaveBeenCalledWith time, time+1, undefined, 0
      expect(tw2._update).toHaveBeenCalledWith time, time+1, undefined, 0

  describe '_setStartTime method ->', ->
    it 'should call super _setStartTime method', ->
      t = new Timeline
      spyOn Timeline.prototype, '_setStartTime'
      t._setStartTime()
      expect(Timeline.prototype._setStartTime).toHaveBeenCalled()

    it 'should call _startTimelines method', ->
      t = new Timeline
      spyOn t, '_startTimelines'
      t._setStartTime()
      expect(t._startTimelines).toHaveBeenCalledWith t._props.startTime

  describe '_startTimelines method ->', ->
    it 'should set time to startTime if no time was passed', ->
      t   = new Timeline
      t.add (new Tween duration: 500), (new Tween duration: 600)
      spyOn t._timelines[0], '_setStartTime'
      spyOn t._timelines[1], '_setStartTime'
      t._startTimelines(null)
      expect(t._timelines[0]._setStartTime).toHaveBeenCalledWith t._props.startTime
      expect(t._timelines[1]._setStartTime).toHaveBeenCalledWith t._props.startTime
    it 'should add self shiftTime to child timelines', ->
      t   = new Timeline
      t.add new Tween duration: 500
      time = 0; shift = 500
      t._setProp 'shiftTime': shift
      t._setStartTime time
      expect(t._timelines[0]._props.startTime).toBe time + shift

  describe '_pushTimeline method ->', ->
    it 'should push timeline to timelines and calc repeatTime',->
      t = new Timeline
      tw = new Tween duration: 4000
      t._pushTimeline tw
      expect(t._timelines.length).toBe 1
      expect(t._timelines[0] instanceof Tween).toBe true
      expect(t._timelines[0]).toBe tw
      expect(t._props.duration).toBe 4000
    it 'should calc time regarding tween\'s speed' ,->
      t = new Timeline
      tw = new Tween duration: 4000, speed: .1
      t._pushTimeline tw
      expect(t._timelines.length).toBe 1
      expect(t._timelines[0] instanceof Tween).toBe true
      expect(t._timelines[0]).toBe tw
      expect(t._props.duration).toBe 40000
    it 'should call _recalcDuration method',->
      t = new Timeline
      tw = new Tween duration: 4000
      spyOn t, '_recalcDuration'
      t._pushTimeline tw
      expect(t._recalcDuration).toHaveBeenCalledWith(tw)

  describe 'append method ->', ->
    it 'should add timeline',->
      t = new Timeline
      t.append new Tween
      expect(t._timelines.length).toBe 1
      expect(t._timelines[0] instanceof Tween).toBe true
    it 'should call _calcDimentions method',->
      t = new Timeline
      spyOn t, '_calcDimentions'
      t.append new Tween
      expect(t._calcDimentions).toHaveBeenCalled()
    it 'should treat every argument as new append call',->
      t = new Timeline
      tm1 = new Tween duration: 1000, delay: 500
      tm2 = new Tween duration: 1000, delay: 700
      t.append tm1, tm2
      expect(t._timelines.length).toBe 2
      expect(t._timelines[0] instanceof Tween).toBe true
      expect(t._timelines[1] instanceof Tween).toBe true
      expect(t._timelines[1]._props.shiftTime).toBe 1500
      expect(t._props.time).toBe 3200
    it 'should treat arrays as parallel tweens #1', ->
      t = new Timeline
      tm1 = new Tween(duration: 500, delay: 500)
      tm2 = new Tween(duration: 500, delay: 700)
      tm3 = new Tween(duration: 500, delay: 700)
      t.append tm1, [tm2, tm3]
      expect(t._props.time).toBe 2200
    it 'should treat arrays as parallel tweens #2', ->
      t = new Timeline
      tm1 = new Tween(duration: 500, delay: 800)
      tm2 = new Tween(duration: 500, delay: 700)
      tm3 = new Tween(duration: 500, delay: 700)
      t.append [tm2, tm3], tm1
      expect(t._props.repeatTime).toBe 1200 + 1300
    it 'should arguments time = array time', ->
      # t = new Timeline delay: 2500
      t1 = new Timeline delay: 2500
      t2 = new Timeline delay: 2500
      tm0 = new Tween duration: 3000, delay: 200
      tm1 = new Tween(duration: 500, delay: 800)
      tm2 = new Tween(duration: 500, delay: 800)
      t1.add tm0; t2.add tm0
      t1.append tm1
      t2.append [tm2]
      time = performance.now()
      t1._setStartTime(time); t2._setStartTime(time)
      expect( Math.abs( tm2._props.startTime - tm1._props.startTime ) )
        .not.toBeGreaterThan 20
    it 'should delay the timeline to duration',->
      t = new Timeline
      t.add new Tween duration: 1000, delay: 200
      t.append new Tween duration: 500, delay: 500
      expect(t._timelines[1]._props.shiftTime).toBe 1200
    it 'should recalc duration',->
      t = new Timeline
      t.add new Tween duration: 1000, delay: 200
      t.append new Tween duration: 500, delay: 500
      expect(t._props.time).toBe 2200
    it 'should work with array',->
      t = new Timeline
      t.add new Tween duration: 1000, delay: 200
      tm1 = new Tween(duration: 500, delay: 500)
      tm2 = new Tween(duration: 500, delay: 700)
      t.append [tm1, tm2]
      expect(t._timelines.length).toBe 3
      expect(t._props.time).toBe 2400
    it 'should work with one argument',->
      t = new Timeline
      t.append new Tween duration: 1000, delay: 200
      expect(t._timelines.length).toBe 1
    it 'should work with multiple arguments',->
      t = new Timeline
      tm1 = new Tween(duration: 500, delay: 500)
      tm2 = new Tween(duration: 500, delay: 700)
      t.append tm1, tm2
      expect(t._timelines.length).toBe 2
    it 'should work with array and set the indexes',->
      t = new Timeline
      t.add new Tween duration: 1000, delay: 200
      tm1 = new Tween(duration: 500, delay: 500)
      tm2 = new Tween(duration: 500, delay: 700)
      t.append [tm1, tm2]
      expect(tm1.index).toBe 1
      expect(tm2.index).toBe 1
    it 'should add element index',->
      t = new Timeline
      t.append new Tween duration: 1000, delay: 200
      t.append new Tween duration: 1000, delay: 200
      expect(t._timelines[0].index).toBe 0
      expect(t._timelines[1].index).toBe 1

  # describe 'remove method ->', ->
  #   it 'should remove timeline',->
  #     t = new Timeline
  #     timeline = new Tween
  #     t.add timeline
  #     t.remove timeline
  #     expect(t.timelines.length).toBe 0
  #   it 'should remove tween',->
  #     t1 = new Timeline
  #     t = new Timeline
  #     timeline = new Tween
  #     t.add timeline
  #     t1.add t
  #     t1.remove t
  #     expect(t1.timelines.length).toBe 0
  
  describe '_recalcTotalDuration method ->', ->
    it 'should recalculate duration', ->
      t = new Timeline
      timeline = new Tween  duration: 100
      timeline2 = new Tween duration: 1000
      t.add timeline
      t._timelines.push timeline2
      t._recalcTotalDuration()
      expect(t._props.duration).toBe 1000
  
  describe 'setProgress method ->', ->
    it 'should call _setStartTime if there is no this._props.startTime', ->
      t = new Timeline
      spyOn t, '_setStartTime'
      t.setProgress .5
      expect(t._setStartTime).toHaveBeenCalled()
    it 'should return self', ->
      t = new Timeline
      result = t.setProgress .5
      expect(result).toBe t
    it 'should call self update', ->
      duration = 500; progress = .75
      t   = new Timeline
      t.add new Tween duration: duration
      spyOn t, '_update'
      t.setProgress progress
      expect(t._update).toHaveBeenCalledWith t._props.startTime + (progress*duration)
    it 'should not set the progress less then 0', ->
      delay = 5000
      t   = new Timeline delay: delay; t1  = new Timeline
      t1.add new Tween duration: 500, delay: 200
      t.add(t1)
      spyOn t, '_update'
      t.setProgress -1.5
      expect(t._update).toHaveBeenCalledWith t._props.startTime - delay
    it 'should not set the progress more then 1', ->
      delay  = 200
      t   = new Timeline delay: delay; t1  = new Timeline
      t1.add new Tween duration: 500, delay: 200
      t.add(t1)
      spyOn t, '_update'
      t.setProgress 1.5
      expect(t._update).toHaveBeenCalledWith (t._props.startTime - delay) + t._props.repeatTime
