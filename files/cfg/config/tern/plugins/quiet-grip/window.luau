--!strict

-- Hide each pane's "Drag to move the pane" grip until the pointer is near it.
-- Tern sets the grip's opacity itself, so these rules need !important. The ::before area
-- widens the hover target; clicks in that area also reach the grip.
tern.css("grip", [[
.tn-pane > .tn-grip {
	opacity: 0 !important;
	transition: opacity 120ms ease;
}

.tn-pane > .tn-grip::before {
	content: "";
	position: absolute;
	top: -8px;
	bottom: -8px;
	left: -24px;
	right: -24px;
}

.tn-pane > .tn-grip:hover,
.tn-pane > .tn-grip:active,
.tn-pane > .tn-grip:focus-visible {
	opacity: 1 !important;
}
]])
