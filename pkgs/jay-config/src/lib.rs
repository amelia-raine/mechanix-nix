use jay_config::*;
use exec::Command;
use video::*;
use theme::*;
use colors::*;
use input::*;
use window::*;
use keyboard::mods::*;
use keyboard::syms::*;

fn configure() {
	let seat = get_default_seat();

	on_graphics_initialized(move || {
		seat.set_workspace(get_workspace("1"));
		Command::new("mechanix-launcher")
			.spawn();
	});

	set_show_bar(false);

	let amber = Color::new(197, 118, 0);
	set_color(BACKGROUND_COLOR, Color::BLACK);
	set_color(HIGHLIGHT_COLOR, amber);
	set_color(FOCUSED_TITLE_BACKGROUND_COLOR, amber);
	set_color(FOCUSED_TITLE_TEXT_COLOR, Color::BLACK);

	seat.bind(ALT | SYM_q, quit);
	seat.bind(CTRL | ALT | SYM_Delete, quit);
	seat.bind(ALT | SYM_c, move || seat.close());
	seat.bind(ALT | SYM_k, move || seat.window().client().kill());
	seat.bind(ALT | SYM_f, move || seat.toggle_floating());
	seat.bind(ALT | SHIFT | SYM_f, move || seat.toggle_fullscreen());
	seat.bind(ALT | SYM_b, move || toggle_show_bar());
	seat.bind(SYM_Super_L, move || minimize_all_windows(seat));
	seat.bind(SYM_Super_R, move || minimize_all_windows(seat));
	seat.bind(ALT | SYM_Super_L, || Command::new("bemenu-run").spawn());
	seat.bind(ALT | SYM_Super_R, || Command::new("bemenu-run").spawn());
	seat.bind(ALT | SYM_t, || Command::new("alacritty").spawn());
	seat.bind(CTRL | ALT | SYM_t, || Command::new("alacritty").spawn());

	for i in 1..=9 {
		let num_key = KeySym(SYM_0.0 + i);
		let workspace = get_workspace(&format!("{i}"));
		seat.bind(ALT | num_key, move || seat.show_workspace(workspace));
		seat.bind(ALT | SHIFT | num_key, move || seat.set_workspace(workspace));
	}

	for i in 1..=7 {
		let f_key = KeySym(SYM_F1.0 - 1 + i);
		seat.bind(CTRL | ALT | f_key, move || switch_to_vt(i));
	}
}

fn minimize_all_windows(seat: Seat) {
	let minimized_ws = get_workspace("minimized");
	apply_window_recursive(
		seat.get_workspace().window(),
		&mut |window| window.set_workspace(minimized_ws)
	);
}

fn apply_window_recursive<F: FnMut(Window)>(window: Window, f: &mut F) {
	let window_type = window.type_();
	if (window_type & CLIENT_WINDOW).0 != 0 {
		f(window);
	}
	if (window_type & CONTAINER).0 != 0 {
		for child in window.children() {
			apply_window_recursive(child, f);
		}
	}
}

config!(configure);
