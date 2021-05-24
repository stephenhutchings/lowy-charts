class Clock {
  constructor(id, initial) {
    
    this.timezone = parseInt(document.getElementById(id).dataset.timezone);
    
    if (this.isDST(new Date())) {
      this.timezone += 1;
    }
 
    this.handSeconds = document.querySelector(`#${id} .hand.seconds`);
    this.handMinutes = document.querySelector(`#${id} .hand.minutes`);
    this.handHours = document.querySelector(`#${id} .hand.hours`);
    this.AMPM = document.querySelector(`#${id} .am-pm`);
    
    if (initial) {
      this.initial = initial
      this.start = new Date()
      this.getElapsed();
      this.cycleElapsed();
    } else {
      this.getTime();
      this.cycle();
    }
  }
  
  isDST(now) {
    const jan = new Date(now.getFullYear(), 0, 1);
    const jul = new Date(now.getFullYear(), 6, 1);
    const dst = Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
    
    return now.getTimezoneOffset() < dst;
  }
  
  draw(hours, minutes, seconds, ampm) {
    const drawSeconds = ((seconds / 60) * 360) + 90;
    const drawMinutes = ((minutes / 60) * 360) + 90;
    const drawHours = ((hours / 12) * 360) + 90;
    
    this.handSeconds.style.transform = `rotate(${drawSeconds}deg)`;
    this.handMinutes.style.transform = `rotate(${drawMinutes}deg)`;
    this.handHours.style.transform = `rotate(${drawHours}deg)`;
    this.AMPM.innerHTML = ampm;
    
    // fix for animation bump on when clock hands hit zero
    // if (drawSeconds === 444 || drawSeconds === 90) {
    //   this.handSeconds.style.transition = "all 0s ease 0s";
    // } else {
    //   this.handSeconds.style.transition = "all 0.05s cubic-bezier(0, 0, 0.52, 2.51) 0s";
    // }
  }
  
  getTime() {
    const now = new Date();

    const hours = now.getUTCHours() + this.timezone;
    const minutes = now.getUTCMinutes();
    const seconds = now.getUTCSeconds();
    
    this.draw(hours, minutes, seconds);
  }

  cycle() {
    setInterval(this.getTime.bind(this), 1000);
  }
  
  getElapsed(s) {
    const now = new Date();
    const hours   = this.initial.getUTCHours()   + now.getUTCHours()   - this.start.getUTCHours();
    const minutes = this.initial.getUTCMinutes() + now.getUTCMinutes() - this.start.getUTCMinutes();
    const seconds = this.initial.getUTCSeconds() + now.getUTCSeconds() - this.start.getUTCSeconds();
    const ampm = hours > 12 ? 'PM' : 'AM'
    
    this.draw(hours, minutes, seconds, ampm);
  }
  
  cycleElapsed() {
    setInterval(this.getElapsed.bind(this), 1000);
  }
  
}

new Clock('beijing', new Date('May 2, 00 13:00:00 GMT+00:00'));
new Clock('canberra', new Date('May 2, 00 15:00:00 GMT+00:00'));
new Clock('washington', new Date('May 2, 00 01:00:00 GMT+00:00'));
