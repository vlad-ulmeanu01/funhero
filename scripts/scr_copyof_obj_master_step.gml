///the actual copy of obj_master.step is compressed in obj_master.object
///this doesn't do anything
/// main loop

var posx, posy; /// position in 3.
var i, j, linefind;
var add, addscore, addmulti;
var key;
var isfind;
var nrlongnotes;
var cur, flag;

if ( frac ( global.cyc ) == 0.0 )
{
    if ( global.cyc < global.hits_y[global.nrnotes] + global.nr_lne + 10 && global.nofail - global.nofailnote > global.epsilon )
    {
        /// FUN: move columns
        script_execute ( scr_fun_col );
        
        /// FUN: scale notes
        script_execute ( scr_fun_sca );
        
        /// FUN: deepfry
        script_execute ( scr_fun_fry );
             
        /// 0. reset fire
        for ( i = 1; i <= global.nr_col; i++ )
            with ( global.notefire[i] )
                sprite_index = spr_notehit_transp;

        /// 1. check notes
        if ( global.lline == 1 ) /// || global.hit == 1
        {
            /// find last line with at least one not played note on it
            isfind = 0;
            j = global.nr_lne;
            while ( j >= global.nr_lne - global.linehit && isfind == 0 )
            {
                for ( i = 1; i <= global.nr_col; i++ )
                {
                    with ( global.obj [ i, j ] )
                    {
                        key = global.nloc[ i, j ];
                        if ( key > 0 && global.nplayed[key] == 0 )
                        {
                            isfind = 1;
                            i = global.nr_col;
                        }
                    }
                }
                if ( isfind == 0 )
                    j--;
            }
            
            linefind = j;
            
            /// mark found notes on linefind
            nrlongnotes = 0;
            add = 0;
            addscore = 0;
            addmulti = global.multiplier;
            for ( i = 1; i <= global.nr_col; i++ )
                with ( global.obj[ i, j ] )
                {
                    key = global.nloc[ i, j ];
                    if ( key > 0 ) //( sprite_index == global.sprites_ty2[i] )
                    {
                        add++;
                        global.kneed[i] = 1;
                        if ( global.tynote[key] > 0 )
                            nrlongnotes++;
                        
                        addscore += ( global.nscore[key] * floor ( addmulti ) );
                        addmulti += ( global.multiinc * ( global.nscore[key] / global.defscore ) );
                        if ( addmulti - 4.0 > global.epsilon )
                            addmulti = 4.0;
                    }
                }
            
            i = 1;
            while ( i <= global.nr_col && global.kpres[i] == global.kneed[i] )
                i++;

            if ( i == global.nr_col + 1 ) /// && add > 0
            {
                /// increase nofail percentage
                global.nofail = min ( 1.0, global.nofail + global.nofailnote * ( add - nrlongnotes ) );
                global.nofail = min ( 1.0, global.nofail + global.nofailnote * nrlongnotes * global.longnotecut * global.longnotecut );
                /// fire pressed notes and mark them as played
                for ( i = 1; i <= global.nr_col; i++ )
                    if ( global.kneed[i] == 1 )
                    {
                        global.nplayed[key] = 1;
                        with ( global.notefire[i] )
                            sprite_index = spr_notehit;
                    }

                global.nhit += add;
                global.sngscore += addscore;
                global.multiplier = addmulti;
            }
            else if ( global.hit == 1 || linefind == global.nr_lne ) /// the note is missed only if it was mispressed or it was on the last line ( i.e. you can't hit it anymore )
            {              
                /// check for any sustain notes that weren't the first ones in line
                i = 1;
                while ( i <= global.nr_col && global.tynote[global.nloc[ i, linefind ]] != 2 )
                    i++;
                
                if ( i > global.nr_col ) /// reset multiplier only if no begun sustain note was missed
                {
                    global.multiplier = 1;
                    // play missed note sound
                    audio_play_sound ( snd_miss, 1, false );
                }
                
                /// decrease nofail
                global.nofail = max ( 0.0, global.nofail - global.nofailnote * ( add - nrlongnotes ) );
                global.nofail = max ( 0.0, global.nofail - global.nofailnote * nrlongnotes * global.longnotecut );
                /// cut sustained notes off
                for ( i = 1; i <= global.nr_col; i++ )
                {
                    key = global.nloc [ i, linefind ];
                    if ( global.tynote[key] > 0 )
                    {
                        j = key;
                        /// go forward until I hit the next line of notes
                        while ( j <= global.nrnotes && global.hits_y[j] == global.hits_y[key] )
                            j++;
                        
                        flag = 1;
                        cur = global.hits_y[key] + 1; /// current line
                        while ( flag == 1 )
                        {
                            flag = 0;
                            while ( j <= global.nrnotes && global.hits_y[j] == cur && global.hits_x[j] != global.hits_x[key] )
                                j++;
                                
                            if ( j <= global.nrnotes && global.hits_y[j] == cur && global.hits_x[j] == global.hits_x[key] ) /// found continued sustain
                            {
                                flag = 1;
                                global.nplayed[j] = 1;
                                while ( j <= global.nrnotes && global.hits_y[j] == cur )
                                    j++;
                                
                                cur++;
                            }
                        }                        
                    }
                }
            }
        }
        
        /// put nofail needle
        with ( obj_needle )
        {
            x = global.nofail_x;
            y = floor ( global.nofail_y + ( 1 - global.nofail ) * 3 * global.tile_sz );
        }

        /// 2. reset tiles
        for ( i = 1; i <= global.nr_col; i++ )
            for ( j = 1; j <= global.nr_lne; j++ )
            {
                global.nloc[ i, j ] = 0;
                with ( global.obj[i, j] )
                    sprite_index = spr_tile;
            }
        
        /// 3. for each note I calculate where it should be

        /// move the starting point forward
        while ( global.start <= global.nrnotes && global.cyc >= global.hits_y[global.start] + global.nr_lne )                
            global.start++;
            
        i = global.start;
        while ( i <= global.nrnotes && global.cyc >= global.hits_y[i] && global.cyc < global.hits_y[i] + global.nr_lne )
        {
            if ( global.nplayed[i] == 0 )
            {
                posy = global.cyc - global.hits_y[i] + 1;
                posx = global.hits_x[i];
                global.nloc[ posx, posy ] = i;
                with ( global.obj[ posx, posy] )
                {
                    if ( global.tynote[i] < 2 )
                        sprite_index = global.sprites_ty1[posx];
                    else
                        sprite_index = global.sprites_ty3[posx];
                }
            }
            i++;
        }

        /// 4. set the last linehit + 1 lines up
        global.lline = 0;
        for ( i = 1; i <= global.nr_col; i++ )
            for ( j = global.nr_lne - global.linehit; j <= global.nr_lne; j++ )
                with ( global.obj [ i, j ] )
                    if ( sprite_index != spr_tile )
                    {
                        sprite_index = global.sprites_ty2[i];
                        global.lline = 1;
                    }
    }
    else
    {
        audio_stop_sound ( snd_rugrats );
        var funvar = " (" + string ( global.fun_fog ) + string ( global.fun_col ) + string ( global.fun_chr ) + string ( global.fun_sca ) + string ( global.fun_fry ) + ")";
        if ( global.nofail - global.nofailnote <= global.epsilon )
            show_message ( "Failed ! Hit " + string ( global.nhit ) + " notes" + funvar );
        else
            show_message ( string ( global.nhit ) + " out of " + string ( global.nrnotes ) + " hit! Accuracy: " + string ( global.nhit / global.nrnotes ) + funvar );
        
        script_execute ( scr_reset );
        room_goto ( room_menu );
    }
    
    /// reset the keys pressed meanwhile and the keys that need to be pressed
    global.hit = 0;
    for ( i = 1; i <= global.nr_col; i++ )
    {
        global.kneed[i] = 0;
        global.kpres[i] = 0;
    }
}
else
{
    /// check for keys pressed
    for ( i = 1; i <= global.nr_col; i++ )
        if ( keyboard_check ( global.keys[i] ) )
        {
            global.hit = 1;
            global.kpres[i] = 1;
        }
}

global.cyc += global.increase;

if ( frac ( global.cyc ) > 0.98 )
    global.cyc = 1 + floor ( global.cyc );
