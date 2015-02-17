/* Copyright 2014 Ryan Sipes & Barry Smith
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

using Gtk;

namespace EvolveJournal {

  public string buffer;
  
  private bool file_loaded;

  public class EvolveWindow : Gtk.ApplicationWindow {

    private Gtk.Button save_button;
    public Gtk.HeaderBar headbar;
    private EvolveNotebook notebook;
    
    public Gtk.ComboBoxText combo_box;
    
    public SimpleAction about_action;
    public SimpleAction saveas_action;
    
    public signal void change_scheme(string scheme);

    public EvolveWindow (Gtk.Application application) 
    {
      Object(application: application);
        
    this.window_position = WindowPosition.CENTER;
    set_default_size (600, 400);

    var headbar = new HeaderBar();
    headbar.set_title("Journal");
    headbar.set_show_close_button(true);
    this.set_titlebar(headbar);

    set_notebook();

    var new_button = new Button.from_icon_name("tab-new-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (new_button);
    new_button.show();
    new_button.set_tooltip_text("New Tab");
    new_button.clicked.connect(()=> {
        notebook.new_tab(notebook.null_buffer, false, "");
      });

    var open_button = new Button.from_icon_name("document-open-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (open_button);
    open_button.show();
    open_button.set_tooltip_text("Open");
    open_button.clicked.connect (() => {
      open_file(notebook);
      });

    var share_button = new Button.from_icon_name("emblem-shared-symbolic", IconSize.SMALL_TOOLBAR);
    share_button.show();
    share_button.set_tooltip_text("Share");
    share_button.clicked.connect (() => {

      if (notebook.get_n_pages() <= 0){
        stdout.printf("No pages! \n");
      }
      else{
        int current_tab = notebook.get_current_page();
        stdout.printf(current_tab.to_string() +"\n");
        string typed_text = notebook.get_text();
        var share = new EvolveJournal.Share();
        share.generate_paste(typed_text, this);
      }

    });

    save_button = new Button.from_icon_name("document-save-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (save_button);
    save_button.show();
    save_button.set_tooltip_text("Save");
    save_button.clicked.connect (() => {
        save_file(notebook, false);
    });

    //Define actions.
    var save_action = new SimpleAction("save_action", null);
    save_action.activate.connect(()=> {
      message("Saving...");
      save_file(notebook, false);
    });

    var open_action = new SimpleAction("open_action", null);
    open_action.activate.connect(()=> {
      message("Opening...");
      open_file(notebook);
      });

    var undo_action = new SimpleAction("undo_action", null);
    undo_action.activate.connect(()=> {
      message("Undo...");
      notebook.undo_source();
      });

    var redo_action = new SimpleAction("redo_action", null);
    redo_action.activate.connect(()=> {
      message("Redo...");
      notebook.redo_source();
      });

    var print_action = new SimpleAction("print_action", null);
    print_action.activate.connect(()=> {
      message("Printing...");
        Gtk.PrintOperation print_operation = new Gtk.PrintOperation();
        print_operation.run(Gtk.PrintOperationAction.PRINT_DIALOG, this);
      });

    saveas_action = new SimpleAction("saveas_action", null);
    saveas_action.activate.connect(()=> {
        message("Saving As...");
        save_file(notebook, true);
      });

    var newtab_action = new SimpleAction("newtab_action", null);
    newtab_action.activate.connect(()=> {
        message("Generating Tab...");
        notebook.new_tab(notebook.null_buffer, false, "");
      });

    about_action = new SimpleAction("about_action", null);
    about_action.activate.connect(()=> {
        queue_draw();
        Idle.add(()=>{
          Gtk.show_about_dialog(this,
            "program-name", "Journal",
            "copyright", "Copyright \u00A9 2015 Ryan Sipes",
            "website", "https://evolve-os.com",
            "website-label", "Evolve OS",
            "license-type", Gtk.License.GPL_2_0,
            "comments", "A simple text-editor with sharing features.",
            "version", "0.7.1 (Beta 3)",
            "logo-icon-name", "journal",
            "artists", new string[]{
              "Alejandro Seoane <asetrigo@gmail.com>"
              },
            "authors", new string[]{
              "Ryan Sipes <ryan@evolve-os.com>",
              "Ikey Doherty <ikey@evolve-os.com>",
              "Barry Smith <barry.of.smith@gmail.com>"
              });
          return false;
          });
      });

    application.set_accels_for_action("app.save_action", {"<Ctrl>S"});
    application.set_accels_for_action("app.open_action", {"<Ctrl>O"});
    application.set_accels_for_action("app.undo_action", {"<Ctrl>Z"});
    application.set_accels_for_action("app.redo_action", {"<Shift><Ctrl>Z"});
    application.set_accels_for_action("app.newtab_action", {"<Ctrl>N"});

    application.add_action(save_action);
    application.add_action(open_action);
    application.add_action(undo_action);
    application.add_action(redo_action);
    application.add_action(print_action);
    application.add_action(saveas_action);
    application.add_action(newtab_action);
    application.add_action(about_action);
    
    
    //Menu button not finished an ready for Beta release.
    MenuButton menu_button = new MenuButton();
    var popover = new Popover(menu_button);
   // popover.set_modal(true);
    
    Gtk.Box menu_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    menu_box.width_request = 100;
    menu_box.visible = true;
    popover.add(menu_box);
    
    Gtk.Button saveas_button = new Gtk.Button();
    saveas_button.visible = true;
    saveas_button.set_relief(ReliefStyle.NONE);
    saveas_button.clicked.connect(()=> {
        message("Saving As...");
        save_file(notebook, true);
      });
    saveas_button.set_label("Save As...");
    menu_box.add(saveas_button);
    
    Gtk.Button about_button = new Gtk.Button();
    about_button.visible = true;
    about_button.set_relief(ReliefStyle.NONE);
    about_button.clicked.connect(()=> {
        queue_draw();
        Idle.add(()=>{
          Gtk.show_about_dialog(this,
            "program-name", "Journal",
            "copyright", "Copyright \u00A9 2015 Ryan Sipes",
            "website", "https://evolve-os.com",
            "website-label", "Evolve OS",
            "license-type", Gtk.License.GPL_2_0,
            "comments", "A simple text-editor with sharing features.",
            "version", "0.7.1 (Beta 3)",
            "logo-icon-name", "journal",
            "artists", new string[]{
              "Alejandro Seoane <asetrigo@gmail.com>"
              },
            "authors", new string[]{
              "Ryan Sipes <ryan@evolve-os.com>",
              "Ikey Doherty <ikey@evolve-os.com>",
              "Barry Smith <barry.of.smith@gmail.com>"
              });
          return false;
          });
      });
    about_button.set_label("About");
    menu_box.add(about_button);
    
    combo_box = new Gtk.ComboBoxText();
    combo_box.set_halign(Gtk.Align.END);
    string[] schemes = Gtk.SourceStyleSchemeManager.get_default().get_scheme_ids();
    for (int count = 0; count < schemes.length; count ++)
        combo_box.append_text(schemes[count]);
    combo_box.changed.connect(() => {this.change_scheme(combo_box.get_active_text());});
    combo_box.set_active(0);
    combo_box.visible = true;
    menu_box.add(combo_box);
    
    //menu_button.image = new Image.from_icon_name("open-menu-symbolic", IconSize.SMALL_TOOLBAR);
    menu_button.set_popover(popover);
    menu_button.show();
    //Gtk.Menu menu = new Gtk.Menu();
    //menu_button.set_menu_model(menu);
    menu_button.set_use_popover(true);
    //menu.append("Print", "app.print_action");
    //menu.append("Save As...", "app.saveas_action");
    //menu.append("About", "app.about_action");
    
    headbar.pack_end (menu_button);
    headbar.pack_end (share_button);

    var vbox = new Box (Orientation.VERTICAL, 0);

    vbox.pack_start(notebook, true, true, 0);
    vbox.show_all();
    this.add (vbox);
    notebook.show_all();
    headbar.show_all();
    }
    
    public void set_notebook(){
      notebook = new EvolveNotebook(this);
    }

    public EvolveNotebook get_notebook(){
      return notebook;
    }

    public void set_loaded(bool loaded){
      file_loaded = loaded;
    }

    public void open_tabs (){
      if (file_loaded != true){
        notebook.new_tab (notebook.null_buffer, false, "");
      }
      else {
        message("File already loaded.");
      }
    }

    public void set_headerbar(string current_file){
      headbar.set_has_subtitle(true);
      headbar.set_subtitle(current_file);
    }

    public Button get_save_button(){
      return save_button;
    }
  }

  public void open_file(EvolveNotebook open_notebook){
    var file = new EvolveJournal.Files();
    buffer = file.on_open_clicked(open_notebook);
    }

  public void save_file(EvolveNotebook save_notebook, bool save_as){
    if (save_notebook.get_n_pages() <= 0){
      stdout.printf("No pages! \n");
    }
    else{
      var file = new EvolveJournal.Files();
      string typed_text = save_notebook.get_text();
      file.on_save_clicked(typed_text, save_notebook, save_as);
    }
  }
}
