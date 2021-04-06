/* --- USER TO UPDATE --- */
const enableTooltips = true
const nSeries = 2
const ttWidth = 90
const ttHeight = 60
const nDatapoints = 25
/* --------------------- */

const chart = document.querySelector('.chart-content')
const vals = document.querySelectorAll('.chart-value text')
const tooltip = document.querySelector('.tooltip')
const tooltipLine = document.querySelector('#tt-line')
const tooltipVals = document.querySelectorAll('.tooltip span')

if (enableTooltips) {
  window.addEventListener('DOMContentLoaded', () => {
    chart.addEventListener('mousemove', triggerTooltip)  
    chart.addEventListener('touchmove', triggerTooltip)  
    chart.addEventListener('mouseleave', () => {
      tooltip.style.opacity = 0
      tooltipLine.style.opacity = 0
    })
})}

const triggerTooltip = e => {
  
  let c = chart.getBoundingClientRect()
  let x = (e.pageX - c.left) / c.width
  let n = nDatapoints - 1
  let o = x > 0.5 ? 0.5 : -0.5
  let i = (x * n + 0).toFixed(0)

  i = i < 0 ? 0 : i > n ? +n : +i
  
  let v = [
    vals[i + n + 1],
    vals[i]
  ]
  
  tooltipLine.setAttribute('y1', v[0].parentElement.getAttribute('y'))
  tooltipLine.setAttribute('y2', v[1].parentElement.getAttribute('y'))
  tooltipLine.setAttribute('x1', v[0].parentElement.getAttribute('x'))
  tooltipLine.setAttribute('x2', v[1].parentElement.getAttribute('x'))
  tooltipLine.style.opacity = 1

  let box = tooltipLine.getBoundingClientRect()
  let offset = i > n/2 ? -100 : 10

  tooltipVals.forEach((e,i) => e.innerHTML = `$${v[i].innerHTML.trim()}B`)
  tooltip.style.top = box.top + box.height/2 - ttHeight/2 + 'px'
  tooltip.style.left = box.left + offset + 'px'
  tooltip.style.opacity = 1

}
