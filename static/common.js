// Common JavaScript functions

// Close form when clicking outside
document.addEventListener('click', function(event) {
    const formContainer = document.getElementById('formContainer');
    if (formContainer && !formContainer.contains(event.target) && 
        !event.target.classList.contains('btn-primary') &&
        event.target.id !== 'formContainer') {
        // Don't close on form clicks
    }
});

// Format currency
function formatCurrency(value) {
    return parseFloat(value).toFixed(2);
}

// Format date
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
}

// Show notification
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}
