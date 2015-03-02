/* Copyright 2014 Ryan Sipes
*
* This file is part of Evolve Journal.
*
* Evolve Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 2 of the
* License, or (at your option) any later version.
*
* Evolve Journal is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Evolve Journal. If not, see http://www.gnu.org/licenses/.
*/

using GLib;

namespace EvolveJournal{

public class App : Gtk.Application{

	private bool window_created = false;
	private File[] loaded_files;
	public bool scheme_action_added;
	private string current_scheme;
	private Settings settings;

	public bool show_tabs { public set; public get; default = false; }

	public App() {
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
		settings = new Settings("com.evolve-os.journal");
		on_settings_change("scheme");
	}

	public override void activate(){
		run_application();	
	}

	//Global Setters and Getters

	public void set_current_scheme(string scheme){
		current_scheme = scheme;
		this.get_windows().foreach((win)=>{
			(win as EvolveJournal.EvolveWindow).change_scheme(scheme);
		});
		set_settings("scheme", scheme);
	}

	public string get_current_scheme(){
		return current_scheme;
	}

	public void set_settings(string key, string val){
		if (key == "scheme"){
			settings.set_string(key, val);
		}
	}

	public void set_window_settings(string key, int val){
		settings.set_int(key, val);
	}

	public int get_window_settings(string key){
		int val = 500;
		if (key == "window-width"){
			val = settings.get_int(key);
		}
		if (key == "window-height"){
			val = settings.get_int(key);
		}
		return val;
	}

	protected void on_settings_change(string key){
		if (key == "scheme"){
			var val = settings.get_string(key);
			set_current_scheme(val);
		}
	}

	public override void open(File[] files, string hint){
		//Load any files requested at startup.
		loaded_files = files;
		if (window_created == false){
			run_application();
		}
		else {
			foreach (File file in loaded_files){
				EvolveJournal.Files file_class = new EvolveJournal.Files();
				var active_win = (EvolveWindow)this.get_active_window();
				file_class.open_at_start(active_win.get_notebook(), file.get_path(), file.get_basename());
			}
		}
	}

	public EvolveWindow create_window(){
		EvolveWindow new_window = new EvolveWindow(this);
		return new_window;
	}

	public void run_application(){
		EvolveWindow first_window = create_window();

		if (loaded_files != null){
			foreach (File file in loaded_files){
				EvolveJournal.Files file_class = new EvolveJournal.Files();
				file_class.open_at_start(first_window.get_notebook(), file.get_path(), file.get_basename());	
			}
			first_window.set_loaded(true);
		}
		else {
			message("No files loaded.");
			first_window.set_loaded(false);
		}

			first_window.open_tabs();
			first_window.present ();	
			window_created = true;
		}
	}

} // End namespace

static int main(string[] args){
	return new EvolveJournal.App ().run (args);
}
