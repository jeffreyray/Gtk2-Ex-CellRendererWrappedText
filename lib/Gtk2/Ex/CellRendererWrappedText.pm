package Gtk2::Ex::CellRendererWrappedText::TextView;

our $VERSION = 0.01;
our $AUTHORITY = 'cpan:JHALLOCK';

use Glib qw(TRUE FALSE);
use Gtk2;
use Gtk2::Gdk::Keysyms;

use Glib::Object::Subclass
	Gtk2::TextView::,
	interfaces => [ 'Gtk2::CellEditable' ],
	;
	
sub set_text {
	my ( $w, $text ) = @_;
	$w->get_buffer->set_text( $text );
}
sub get_text {
	my ( $w ) = @_;
	my $buffer = $w->get_buffer;
	$buffer->get_text ( $buffer->get_start_iter,  $buffer->get_end_iter, TRUE );
}


package Gtk2::Ex::CellRendererWrappedText;
use Glib qw(TRUE FALSE);

use Glib::Object::Subclass
	Gtk2::CellRendererText::,
	;

sub START_EDITING {
	my ($cell, $event, $widget, $path, $background_area, $cell_area, $flags) = @_;
	

	my $e = Gtk2::Ex::CellRendererWrappedText::TextView->new;
	$e->set( 'wrap-mode', $cell->get( 'wrap-mode' ) );
	$e->get_buffer->set_text( $cell->get( 'text' ) );
	$e->set_border_width( $cell->get( 'ypad' ) );
	$e->set_size_request( $cell_area->width - $cell->get( 'ypad' ) , $cell_area->height );
	$e->grab_focus;

	$e->signal_connect ('key-press-event' => sub {
		my ( $widget, $event ) = @_;
		
		# if user presses Ctrl + enter/return then send edited signal
		if ( ( $event->keyval == $Gtk2::Gdk::Keysyms{Return}
			||  $event->keyval == $Gtk2::Gdk::Keysyms{KP_Enter} )
		    and $event->state & 'control-mask'
			) {
			$cell->signal_emit( edited => $path, $widget->get_text);
			$widget->destroy;
			return TRUE;
		}
		
		# if user presses esc - cancel editing
		elsif ( $event->keyval == $Gtk2::Gdk::Keysyms{Esc} ) {
			$widget->destroy;
			return TRUE;
		}
		return FALSE;
	});
    
    # send edited signal on focus out
	$e->signal_connect( 'focus-out-event' => sub {
		my $widget = shift;
		$cell->signal_emit( edited => $path, $widget->get_text );
	});
    
	$e->show;
	return $e;
}

sub RENDER {
	my $cell = shift;
	my ($event, $widget, $path, $background_area, $cell_area, $flags) = @_;
	$cell->set( 'wrap-width', $cell_area->width - $cell->get( 'ypad' ) );
	$cell->SUPER::RENDER( @_ );
}



1;


__END__

=head1 NAME

Gtk2::Ex::CellRendererWrappedText - Widget for displaying and editing multi-line
text entries in a TreeView

=head1 SYNOPSIS

 use Gtk2::Ex::CellRendererWrappedText;
 
 $treeview->new( $model );
 
 $cell = Gtk2::CellRender

 $cell = Gtk2::Ex::CellRendererWrappedText->new;
 
 $cell->set( editable => 1 );
 
 $cell->set( wrap_mode => 'word' );
 
 $cell->set( wrap_width => 400 );
 
 $cell->signal_connect (edited => sub {
		my ($cell, $text_path, $new_text, $model) = @_;
		my $path = Gtk2::TreePath->new_from_string ($text_path);
		my $iter = $model->get_iter ($path);
		$model->set ($iter, 1, $new_text);
	}, $model);

 $column = Gtk2::TreeViewColumn->new_with_attributes( 'Wrapped', $cell, text => 1 );
 
 $column->set_resizable( 1 );
 
 $view->append_column ($column);
 

=head1 WIDGET HIERARCHY

  Glib::Object
  +----Glib::InitiallyUnowned
       +----Gtk2::Object
            +----Gtk2::CellRenderer
                 +----Gtk2::CellRendererText
                      +----Gtk2::Ex::CellRendererWrappedText



=head1 DESCRIPTION

C<Gtk2::Ex::CellRendererWrappedText> is a L<Gtk2::CellRendererText> that
automatically updates the wrap-width of the of the renderer so that the text
always fills (or shrinks to match) the available area.

C<Gtk2::Ex::CellRendererWrappedText> also handles editing of strings that span
multiple lines.  L<Gtk2::CellRendererText> only displays multi-line strings on
one line while in edit mode, regardless of the wrap-wdith of the renderer.

Pressing <Esc> whil in edit mode cancels the edit. Pressing <Enter>  moves to
the next line. Pressing <Ctrl+Enter> or focusing out of the render finishes
editing and emits the 'edited' signal on the renderer. 


=head1 SEE ALSO

L<Gtk2::CellRendererText>,
L<Gtk2::Ex::DateEntry::CellRenderer>, L<Gtk2::Ex::TimeEntry::CellRenderer>

=head1 AUTHOR

Jeffrey Hallock  <jeffrey dot hallock @ gmail dot com>.

Some code adapted from Muppet's customrenderer.pl script included in the
Gtk2 examples directory.

=head1 CAVEATS & BUGS

None known. Please send bugs to <jeffrey dot hallock @ gmail dot com>.
Patches and suggestions welcome.


=head1 LICENSE

Gtk2-Ex-CellRendererText is Copyright 2010 Jeffrey Ray Hallock

Gtk2-Ex-CellRendererText is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Gtk2-Ex-CellRendererText is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Gtk2-Ex-DateEntry.  If not, see L<http://www.gnu.org/licenses/>.

=cut

