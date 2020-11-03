var i, j, rnd, t = 2;

for ( i = 1; i <= global.nr_col; i++ )
{
    rnd = floor ( random ( 2 ) );
    if ( rnd == 0 ) /// move left
        global.col_pos[i] -= ( t * global.fun_col );
    else /// move right
        global.col_pos[i] += ( t * global.fun_col );

    for ( j = 1; j <= global.nr_lne; j++ )
    {
        with ( global.obj [ i, j ] )
            x = global.col_pos[i];
        with ( global.notefire [i] )
            x = global.col_pos[i];
    }
}
