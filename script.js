window.onload = function() {
    const dateTimeElement = document.getElementById("date-time");
    const currentDate = new Date();
    const formattedDate = currentDate.toLocaleString();  // This will get the current date and time
    dateTimeElement.innerHTML = `Current Date and Time: ${formattedDate}`;
};

<script src="script.js" defer></script>
