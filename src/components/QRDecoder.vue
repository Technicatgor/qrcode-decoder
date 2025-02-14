<template>
  <div
    class="min-h-screen bg-gray-900 text-white flex flex-col items-center justify-center p-4"
  >
    <h1 class="text-3xl font-bold mb-8">QR Code Decoder</h1>
    <div class="w-full max-w-md bg-gray-800 rounded-lg p-6 shadow-lg">
      <!-- Camera Feed -->
      <video ref="video" class="w-full h-auto rounded-lg mb-4" autoplay></video>
      <button
        @click="startScan"
        class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg mb-4"
      >
        Start Scanning
      </button>

      <!-- Upload QR Code Image -->
      <div class="mb-4">
        <label class="block text-sm font-medium mb-2"
          >Or upload a QR code image:</label
        >
        <input
          type="file"
          accept="image/*"
          @change="handleFileUpload"
          class="w-full text-sm text-gray-400 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
        />
      </div>

      <!-- Decoded Text -->
      <div v-if="decodedText" class="mt-4 p-4 bg-gray-700 rounded-lg">
        <p class="text-green-400 font-bold">Decoded Text:</p>
        <p class="break-words mb-4">{{ decodedText }}</p>
        <button
          @click="copyText"
          class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg"
        >
          Copy Text
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import jsQR from "jsqr";

const video = ref(null);
const decodedText = ref("");

// Start camera scanning
const startScan = async () => {
  decodedText.value = "";
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: "environment" },
    });
    video.value.srcObject = stream;
    video.value.play();
    requestAnimationFrame(tick);
  } catch (error) {
    console.error("Error accessing camera:", error);
    alert(
      "Unable to access the camera. Please ensure you have granted camera permissions and are using a supported browser.",
    );
  }
};

// Decode QR code from camera feed
const tick = () => {
  if (video.value.readyState === video.value.HAVE_ENOUGH_DATA) {
    const canvas = document.createElement("canvas");
    canvas.width = video.value.videoWidth;
    canvas.height = video.value.videoHeight;
    const context = canvas.getContext("2d");
    context.drawImage(video.value, 0, 0, canvas.width, canvas.height);
    const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
    const code = jsQR(imageData.data, imageData.width, imageData.height);

    if (code) {
      decodedText.value = code.data;
    }
  }
  requestAnimationFrame(tick);
};

// Handle file upload and decode QR code
const handleFileUpload = (event) => {
  const file = event.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        const context = canvas.getContext("2d");
        context.drawImage(img, 0, 0, canvas.width, canvas.height);
        const imageData = context.getImageData(
          0,
          0,
          canvas.width,
          canvas.height,
        );
        const code = jsQR(imageData.data, imageData.width, imageData.height);

        if (code) {
          decodedText.value = code.data;
        } else {
          alert("No QR code found in the image.");
        }
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }
};

// Copy decoded text to clipboard
const copyText = () => {
  if (decodedText.value) {
    navigator.clipboard
      .writeText(decodedText.value)
      .then(() => {
        alert("Text copied to clipboard!");
      })
      .catch((err) => {
        console.error("Failed to copy text: ", err);
        alert("Failed to copy text. Please try again.");
      });
  }
};
</script>
