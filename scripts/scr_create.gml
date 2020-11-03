global.nr_lne = 22; /// 24
global.nr_col = 5;
global.tile_sz = 32;
global.increase = 1 / ( room_speed / 10 ); /// room_speed should be a multiple of 30; 1 / ( room_speed / 10 )
/// variables in Step
global.lline = 0; /// if there are notes on the last line
global.nhit = 0; /// notes hit
global.start = 1; /// starting note in Step
global.hit = 0; /// any key hit?
global.linehit = 2; /// +1 == how many lines can be hit
global.defscore = 50; /// default score for a simple note
global.sngscore = 0; /// song score
global.multiplier = 1; 
global.multiinc = 0.1; /// multiplier increment per hit note
global.epsilon = 0.001; /// error admission value
global.maxscore = 0; /// maximum score ( 4x )
global.nofail = 0.5; /// nofail value
global.nofailnote = 0.03; /// nofail movement per note
global.scorepc = 0.75; /// max. score calculation percentage
global.longnotecut = 1 / 3; /// nofail cut percentage for long notes
global.text_x = 1;
global.text_y = 742; /// 804
global.star_x = 8;
global.star_y = 629; /// 693
global.starproc_x = 1;
global.starproc_y = 598; /// 662
global.nofail_x = 0;
global.nofail_y = 448; /// 512
global.multi_x = 1;
global.multi_y = 544; /// 608

var i, j, nadd = 0, aux, cpy_nl;

var fin = get_open_filename( "", "" );

if ( fin != "" )
{
    var content = file_text_open_read ( fin );

    global.nrnotes = file_text_read_real ( content );
    global.hits_x[global.nrnotes+1] = 0;
    global.hits_y[global.nrnotes+1] = 0;
    global.nscore[global.nrnotes+1] = 0;
    global.tynote[global.nrnotes+1] = 0; /// note type 0 - normal 1 - long
    global.notelen = 0; /// note len if note type is 1

    var ind = 1;

    for ( i = 1; i <= global.nrnotes; i++ )
    {
        global.tynote[ind] = file_text_read_real ( content );
        global.hits_x[ind] = file_text_read_real ( content );
        global.hits_y[ind] = file_text_read_real ( content );
        global.nscore[ind] = global.defscore;
        if ( global.tynote[ind] == 1 )
        {
            global.notelen = file_text_read_real ( content );
            cpy_nl = global.defscore / global.notelen;
            show_debug_message ( string ( cpy_nl ) );
            if ( frac ( cpy_nl ) != 0.0 )
                cpy_nl = 1 + floor ( cpy_nl );
                
            ind++;
            for ( global.notelen--; global.notelen > 0; global.notelen-- ) 
            {
                global.hits_x[ind] = global.hits_x[ind-1];
                global.hits_y[ind] = global.hits_y[ind-1] + 1;
                global.nscore[ind] = cpy_nl;
                global.tynote[ind] = 1;
                ind++;
                nadd++;
            }
        }
        else
            ind++;
    }

    global.nrnotes += nadd;
    /// calculate the maximum score
    global.maxscore = global.scorepc * global.defscore * global.nrnotes;
        
    /// sort the notes after hits_y
    for ( i = 1; i <= global.nrnotes; i++ )
        for ( j = i + 1; j <= global.nrnotes; j++ )
            if ( global.hits_y[i] > global.hits_y[j] || ( global.hits_y[i] == global.hits_y[j] && global.hits_x[i] > global.hits_x[j] ) )
            {
                aux = global.hits_x[i]; global.hits_x[i] = global.hits_x[j]; global.hits_x[j] = aux;
                aux = global.hits_y[i]; global.hits_y[i] = global.hits_y[j]; global.hits_y[j] = aux;
                aux = global.nscore[i]; global.nscore[i] = global.nscore[j]; global.nscore[j] = aux;
                aux = global.tynote[i]; global.tynote[i] = global.tynote[j]; global.tynote[j] = aux;
            }
    
    file_text_close ( content );
    
    global.fileread = 1;
    
    audio_play_sound ( snd_rugrats, 0, false );

    /// place nofail needle
    with ( obj_needle )
    {
        x = global.nofail_x;
        y = global.nofail_y + 3 * global.tile_sz / 2;
    }

    /// put note sprites ( type 1 ) - general notes falling down
    global.sprites_ty1[global.nr_col+1] = 0;
    global.sprites_ty1[1] = spr_green_push;
    global.sprites_ty1[2] = spr_red_push;
    global.sprites_ty1[3] = spr_yellow_push;
    global.sprites_ty1[4] = spr_blue_push;
    global.sprites_ty1[5] = spr_orange_push;
    /// put note sprites ( type 2 ) - notes ready to be hit
    global.sprites_ty2[global.nr_col+1] = 0;
    global.sprites_ty2[1] = spr_green_recv;
    global.sprites_ty2[2] = spr_red_recv;
    global.sprites_ty2[3] = spr_yellow_recv;
    global.sprites_ty2[4] = spr_blue_recv;
    global.sprites_ty2[5] = spr_orange_recv;

    /// keys

    global.keys[global.nr_col+1] = 0;
    global.keys[1] = ord ( "Z" );
    global.keys[2] = ord ( "X" );
    global.keys[3] = ord ( "C" );
    global.keys[4] = ord ( "V" );
    global.keys[5] = ord ( "B" );

    global.kpres[global.nr_col+1] = 0; /// keys pressed meanwhile
    global.kneed[global.nr_col+1] = 0; /// keys that need to be pressed

    global.strum = ord ( "/" );

    /// notes in every object
    global.nloc[global.nr_col + 1, global.nr_lne + 1] = 0;

    /// note played
    global.nplayed[global.nrnotes+1] = 0;

    /// column positions
    global.col_pos[global.nr_col+1] = 0;
    global.col_pos[1] = global.tile_sz * 1;
    global.col_pos[2] = global.tile_sz * 3;
    global.col_pos[3] = global.tile_sz * 5;
    global.col_pos[4] = global.tile_sz * 7;
    global.col_pos[5] = global.tile_sz * 9;

    /// create the tiles

    global.obj[global.nr_col+1, global.nr_lne+1] = 0; /// object array
    for ( i = 1; i <= global.nr_col; i++ )
        for ( j = 1; j <= global.nr_lne; j++ )
        {
            global.obj[i, j] = instance_create ( global.col_pos[i], ( j - 1 ) * global.tile_sz, obj_tile ); /// -1
            with ( global.obj[i, j] )
                depth = -1;
        }
    /// create notehit objects

    global.notefire[global.nr_col+1] = 0;
    for ( i = 1; i <= global.nr_col; i++ )
    {
        global.notefire[i] = instance_create ( global.col_pos[i], ( global.nr_lne - 1 ) * global.tile_sz, obj_notefire ); /// -2
        with ( global.notefire[i] )
            depth = -8;
    }
    global.cyc = 0;

    /// FUN: check fog

    if ( global.fun_fog == 1 )
    {
        global.fog1 = instance_create ( 0, 800 - 512, obj_fog );
        global.fog2 = instance_create ( 0, 800 - 512, obj_thickfog );
        global.fog3 = instance_create ( 0, 800 - 512, obj_thickfog2 );
    }

    /// FUN: create character

    if ( global.fun_chr == 1 )
        global.obchr = instance_create ( 320, 512, obj_dtc );

    show_debug_message ( string ( room_speed ) );
}
else
    room_goto ( room_menu );



