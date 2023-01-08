const input = document.getElementById('ytUrlInput');
const ac = new Autocomplete(input, {
    threshold: 1,
    maximumItems: 10,
    highlightTyped: true,
    highlightClass: 'text-primary',
    data: history,
    onSelectItem: () => {
        input.focus();
    }
});
