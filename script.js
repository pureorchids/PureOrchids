/*
    Pure Orchids Miami - Logic
    Handles Gallery Modal & WhatsApp Form
*/

// --- Gallery Data (Placeholders) ---
// In a real scenario, you'd replace 'Photo 1', 'Photo 2' with actual image URLs.
const galleryData = {
    1: ["Example #1 - Main View", "Example #1 - Close Up", "Example #1 - Angle"],
    2: ["Example #2 - Main View", "Example #2 - Detail"],
    3: ["Example #3 - Main View", "Example #3 - Side", "Example #3 - Top Down"],
    4: ["Example #4 - Full Setup", "Example #4 - Zoom"],
    5: ["Example #5 - Main"],
    6: ["Example #6 - Main", "Example #6 - Alternative"]
};

let currentExampleId = null;
let currentImageIndex = 0;

// --- Modal Elements ---
const modal = document.getElementById('product-modal');
const modalText = document.getElementById('modal-text');
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
    const content = images[currentImageIndex];

    // Update Title
    modalTitle.innerText = `Example #${currentExampleId} (${currentImageIndex + 1}/${images.length})`;

    // Update Image/Placeholder
    // If using real images: document.getElementById('modal-img').src = content;
    modalText.innerText = content;
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