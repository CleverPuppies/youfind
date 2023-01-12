let inputs = document.getElementsByClassName('ytUrlInput');
inputs = Array.prototype.slice.call(inputs);
inputs.forEach(input => {
    new Autocomplete(input, {
        threshold: 1,
        maximumItems: 10,
        highlightTyped: true,
        highlightClass: 'text-primary',
        data: history,
        onSelectItem: () => {
            input.focus();
        }
    });
});
