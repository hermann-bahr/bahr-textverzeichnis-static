// Calendar initialization for bahr-textverzeichnis-static
// Clean version without any old code references

let calendar;
let data = [];

// Convert calendarData format to SimpleCalendar format
let activeFilters = new Set(['artikel', 'buchbeitrag', 'rezension', 'sonstiges']); // All active by default
window.activeFilters = activeFilters; // Make globally available for SimpleCalendar

function processCalendarData() {
  data = calendarData.map(r => ({
    startDate: r.startDate,
    endDate: r.startDate, // Same day event
    name: r.name,
    linkId: r.id,
    category: r.category || 'sonstiges',
    tageszaehler: r.tageszaehler
  }));
}

// Day click handler - preserves original functionality
function handleDayClick(e) {
  const events = e.events;
  const date = e.date;
  
  if (events.length === 1) {
    // Single event - navigate to text
    window.location.href = events[0].linkId;
  } else if (events.length > 1) {
    // Multiple events - show modal
    showEventsModal(events, date);
  }
}

// Show events modal (preserves original modal functionality) - make globally available
function showEventsModal(events, date) {
  window.showEventsModal = showEventsModal; // Make globally available
  // Format date for title without leading zeros
  const day = date.getDate();
  const month = date.getMonth() + 1;
  const year = date.getFullYear();
  const dateStr = `${day}.${month}.${year}`;
  
  let html = "<div class='modal fade' id='dialogForLinks' tabindex='-1' aria-labelledby='modalLabel' aria-hidden='true'>";
  html += "<div class='modal-dialog' role='document'>";
  html += "<div class='modal-content'>";
  html += "<div class='modal-header'>";
  html += "<h5 class='modal-title' id='modalLabel'>Texte vom " + dateStr + "</h5>";
  html += "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>";
  html += "</div><div class='modal-body'>";
  
  // Category colors mapping
  const categoryColors = {
    'artikel': '#A63437',    // Articles (red)
    'buchbeitrag': '#1C6E8C', // Book contributions (blue)
    'rezension': '#68825b',   // Reviews (green)
    'sonstiges': 'rgb(101, 67, 33)'  // Other texts (brown)
  };
  
  // Sort events by tageszaehler (preserving original sorting logic)
  let numbersTitlesAndIds = [];
  events.forEach((event, i) => {
    numbersTitlesAndIds.push({
      'i': i,
      'position': event.tageszaehler,
      'linkTitle': event.name,
      'id': event.linkId,
      'category': event.category
    });
  });
  
  numbersTitlesAndIds.sort((a, b) => {
    let positionOne = parseInt(a.position);
    let positionTwo = parseInt(b.position);
    if (positionOne < positionTwo) return -1;
    if (positionOne > positionTwo) return 1;
    return 0;
  });
  
  // Add texts
  numbersTitlesAndIds.forEach(item => {
    const color = categoryColors[item.category] || '#999999';
    html += "<div class='indent' style='margin: 8px 0;'>";
    html += "<a href='" + item.id + "' style='color: " + color + "; text-decoration: none; font-weight: 500; display: block; padding: 4px 0;'>" + item.linkTitle + "</a>";
    html += "</div>";
  });
  
  html += "</div>";
  html += "<div class='modal-footer'>";
  html += "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Schließen</button>";
  html += "</div></div></div></div>";
  
  // Remove existing modal and add new one
  $('#dialogForLinks').remove();
  $('#loadModal').append(html);
  $('#dialogForLinks').modal('show');
}

// Initialize calendar when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  console.log('Initializing calendar...');
  
  // Check if calendar container exists
  if (!document.getElementById('calendar')) {
    console.error('Calendar container not found');
    return;
  }
  
  // Check if calendarData exists
  if (typeof calendarData === 'undefined') {
    console.error('calendarData not found');
    return;
  }
  
  // Process calendar data
  processCalendarData();
  console.log('Processed calendar data:', data.length, 'events');
  
  // Make functions globally available for simple-calendar.js
  window.showEventsModal = showEventsModal;
  
  // Initialize SimpleCalendar
  try {
    calendar = new SimpleCalendar('calendar', {
      startYear: 1890,
      dataSource: data,  // Use all data, filtering is handled inside SimpleCalendar
      clickDay: handleDayClick
    });
    console.log('Calendar initialized successfully');
  } catch (error) {
    console.error('Error initializing calendar:', error);
  }
});