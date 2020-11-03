global.start = 1;
global.nhit = 0;
global.sngscore = 0;
global.multiplier = 1;
global.cyc = 0.0;

with ( obj_tile )
    instance_destroy ();
with ( obj_notefire )
    instance_destroy ();
with ( obj_fog )
    instance_destroy ();
with ( obj_thickfog )
    instance_destroy ();
with ( obj_thickfog2 )
    instance_destroy ();
with ( obj_dtc )
    instance_destroy ();
    
var i, j;

for ( i = 1; i <= global.nrnotes; i++ )
{
    global.hits_x[i] = 0;
    global.hits_y[i] = 0;
    global.nscore[i] = 0;
    global.tynote[i] = 0;
}

/// nloc si nplayed

for ( i = 1; i <= global.nr_col; i++ )
    for ( j = 1; j <= global.nr_lne; j++ )
        global.nloc [ i, j ] = 0;
        
for ( i = 1; i <= global.nrnotes; i++ )
    global.nplayed[i] = 0;
