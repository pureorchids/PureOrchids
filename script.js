/*
    Pure Orchids Miami - Logic
    Handles Gallery Modal & WhatsApp Form
*/

// --- Gallery Data (Real Images) ---
// Folders: Orchid #1, Orchid #2, etc. (URL Encoded: Orchid%20%231)
const galleryData = {
    1: ["Orchid%20%231/1.1.jpg", "Orchid%20%231/2.1.jpg"],
    2: ["Orchid%20%232/1.2.jpg", "Orchid%20%232/2.2.jpg", "Orchid%20%232/3.2.jpg"],
    3: ["Orchid%20%233/1.3.jpg"],
    4: ["Orchid%20%234/1.4.jpg", "Orchid%20%234/2.4.jpg"]
};

let currentExampleId = null;
let currentImageIndex = 0;

// --- Modal Elements ---
const modal = document.getElementById('product-modal');
const modalImg = document.getElementById('modal-img');
const modalTitle = document.getElementById('modal-title');

// --- Functions ---

function openModal(id) {
    if (!galleryData[id]) return;

    currentExampleId = id;
    currentImageIndex = 0;

    updateModalContent();
    modal.classList.add('active'); // Show modal
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
}

function closeModal() {
    modal.classList.remove('active');
    document.body.style.overflow = 'initial'; // Restore scrolling
}

function nextImage() {
    if (!currentExampleId) return;
    const images = galleryData[currentExampleId];
    currentImageIndex = (currentImageIndex + 1) % images.length;
    updateModalContent();
}

function prevImage() {
    if (!currentExampleId) return;
    const images = galleryData[currentExampleId];
    // Loop backwards correctly
    currentImageIndex = (currentImageIndex - 1 + images.length) % images.length;
    updateModalContent();
}

function updateModalContent() {
    const images = galleryData[currentExampleId];
    const imageSrc = images[currentImageIndex];

    // Update Title
    modalTitle.innerText = `Orchid #${currentExampleId} (${currentImageIndex + 1}/${images.length})`;

    // Update Image
    modalImg.src = imageSrc;
}


// --- Event Listeners ---

// Close on outside click
modal.addEventListener('click', (e) => {
    if (e.target === modal) {
        closeModal();
    }
});

// WhatsApp Form Logic (Moved from inline to here for cleanliness)
function sendToWhatsApp(event) {
    event.preventDefault();

    const name = document.getElementById('name').value;
    const phone = document.getElementById('phone').value;
    const flower = document.getElementById('flower').value;
    const notes = document.getElementById('message').value;

    const ownerPhone = "17865154855";

    const text = `Hello Pure Orchids, I would like to make an inquiry.%0A%0A*Name:* ${name}%0A*Phone:* ${phone}%0A*Requesting:* ${flower}%0A*Notes:* ${notes}`;

    const url = `https://wa.me/${ownerPhone}?text=${text}`;

    window.open(url, '_blank').focus();
}
