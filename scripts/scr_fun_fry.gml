if ( global.fun_fry == 1 )
{
    var i, j;
    var hue, sat, val;
    var col;
    
    /// lights
    for ( i = 1; i <= global.nr_lights; i++ )
        with ( global.fun_lights[i] )
        {
            x += ( irandom ( 20 ) - 10 );
            y += ( irandom ( 20 ) - 10 );
            x = max ( 0, x ); x = min ( room_width, x );
            y = max ( 0, y ); y = min ( room_height, y );
        }
        
    /// noise : sin for hspeed cos for vspeed
    global.angle = ( global.angle + global.angle_increase ) % 360;
    global.noise_hue = max ( ( global.noise_hue + 5 ) % 360, 120 );
    global.noise_sat = max ( ( global.noise_sat + 5 ) % 255, 128 );
    val = colour_get_value ( c_aqua );
    
    var sn = sin ( pi / 180 * global.angle ), cs = cos ( pi / 180 * global.angle );
    
    with ( global.noise )
    {
        x += ( global.angle_magnitude * sn );
        y += ( global.angle_magnitude * cs );
        x = max ( 0, x ); x = min ( room_width, x );
        y = max ( 0, y ); y = min ( room_height, y );
        image_blend = make_colour_hsv ( global.noise_hue, global.noise_sat, val );
        if ( image_angle >= 20 || image_angle <= -20 )
            global.angle_dir *= -1;
        
        image_angle += ( global.angle_dir * global.angle_magnitude / 10 );        
    }
    
    for ( i = 1; i <= global.nr_col; i++ )
        for ( j = 1; j <= global.nr_lne; j++ )
            with ( global.obj [ i, j ] )
            {
                image_xscale = sn;
                image_yscale = cs;
            }
    
    /// FUN: deepdry friteuse
    
    if ( global.cyc < 1 )
    {
        for ( i = 1; i <= global.nr_col; i++ )
        {
            //global.fun_hue[i] = max ( ( global.fun_hue[i] + 5 ) % 360, 60 );
            //global.fun_sat[i] = max ( ( global.fun_sat[i] + 5 ) % 255, 64 );
            global.fun_hue[i] = ( global.fun_hue[i] + 180 ) % 360;
            global.fun_sat[i] = 255;
        }
    
        for ( i = 1;i <= global.nr_col; i++ )
            for ( j = 1; j <= global.nr_lne; j++ )
            {
                col = global.col_col[i];    
                val = colour_get_value ( col );
                with ( global.obj [ i, j ] )          
                    image_blend = make_colour_hsv ( global.fun_hue[i], global.fun_sat[i], val );
            }
    }
}
