// AdminKit — Minimal JS + LiveView hooks

const AdminKitHooks = {
  // Auto-dismiss flash messages after 5 seconds
  FlashAutoDismiss: {
    mounted() {
      this.timer = setTimeout(() => {
        this.el.style.transition = "opacity 0.3s ease-out";
        this.el.style.opacity = "0";
        setTimeout(() => this.el.remove(), 300);
      }, 5000);
    },
    destroyed() {
      if (this.timer) clearTimeout(this.timer);
    }
  },

  // Confirm before destructive actions
  ConfirmAction: {
    mounted() {
      this.el.addEventListener("click", (e) => {
        const message = this.el.dataset.confirm;
        if (message && !window.confirm(message)) {
          e.preventDefault();
          e.stopPropagation();
        }
      });
    }
  }
};

export { AdminKitHooks };
export default AdminKitHooks;
