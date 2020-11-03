///the actual copy of obj_master.draw is compressed in obj_master.object
///this doesn't do anything
draw_self ();

draw_set_halign ( fa_top );
draw_set_valign ( fa_left );

if ( global.fun_fog == 0 )
    draw_set_color ( c_white );
else
    draw_set_color ( c_black );
    
draw_set_font ( fnt_default );

/// draw accuracy and score
var val;

if ( global.start == 1 )
    val = 0;
else
    val = global.nhit / ( global.start - 1 );

draw_text ( global.text_x, global.text_y, "Accuracy: " + string ( val ) + " Score: " + string ( global.sngscore ) );

/// draw multiplier

draw_text ( global.multi_x, global.multi_y, string ( floor ( global.multiplier ) ) + "x" );

/// draw number of stars

var nst = 0; /// nr of stars
var comp = 0.1;

while ( 1 - comp > global.epsilon && global.sngscore - comp * global.maxscore > global.epsilon )
{
    nst++;
    comp += 0.2;
}

draw_text ( global.star_x, global.star_y, string ( nst ) );

/// draw percentage completed until next star

var oldcomp = max ( 0, comp - 0.2 );
val = ( global.sngscore - oldcomp * global.maxscore ) / ( global.maxscore * ( comp - oldcomp ) ) * 100;

if ( nst < 5 )
    draw_text ( global.starproc_x, global.starproc_y, string ( floor ( val ) ) + "%" );
else
    draw_text ( global.starproc_x, global.starproc_y, "gg" );
    
/// nofail

draw_text ( 1 + global.nofail_x, global.nofail_y - 32, string ( floor ( 100 * global.nofail ) ) );
