declare variable $Year external;
declare variable $Type external;

declare variable $InvalidYear := "Invalid Year";
declare variable $InvalidType := "Invalid Type";

declare function local:validateYear() as xs:boolean
{
    fn:number($Year) >= 2013 and fn:number($Year) <= 2021 
};

declare function local:validateType() as xs:boolean
{
    fn:string($Type) = "sc" or
    fn:string($Type) = "xf" or 
    fn:string($Type) = "cw" or
    fn:string($Type) = "go" or 
    fn:string($Type) = "mc" or 
    ( fn:string($Type) = "enas" and fn:number($Year) >= 2020 and fn:number($Year) < 2022 )
};

declare function local:validateParameters() as xs:boolean
{
    local:validateType() and local:validateYear()
};

(: Chequea si el current driver de drivers_list.xml aparece en drivers_standings.xml :)
declare function local:belongs($id as xs:string) as xs:boolean
{
    let $driver := doc('drivers_standings.xml')//series/season/driver[@id = $id]
    return
    exists($driver)
};

(: Retorna el nodo drivers con la informacion de cada driver :)
declare function local:drivers() as node()
{
    <drivers>
    {
    (: Itera por todos los drivers :)
    for $d in doc('drivers_list.xml')//series/season/driver
    return
        <driver>
            <full_name> {xs:string($d/@full_name)}</full_name>
            <country> {xs:string($d/@country)} </country>
            <birth_date> {xs:string($d/@birthday)} </birth_date>
            <birth_place> {xs:string($d/@birth_place)} </birth_place>
            <rank>
            {
                (: Setea el rank del driver si es que esta presente en drivers_standings.xml :)
                if(local:belongs($d/@id)) then (
                for $driver in doc('drivers_standings.xml')//series/season/driver[@id = $d/@id]
                return
                xs:string($driver/@rank)
                )
                else xs:string("-")
            }
            </rank>

            {
                (: Si el driver tiene por lo menos un auto entonces el nodo car
                contiene el nombre del manufacturer del primer auto:)
                if (count($d/car) > 0) then (<car> {xs:string($d/car[1]/manufacturer/@name)} </car>)
                else() 
            }
            
            {
                (: Si el driver esta presente en drivers_standings.xml, obtenemos la informacion
                de algunas de sus estadisticas:)
                if(local:belongs($d/@id)) then (
                for $driver in doc('drivers_standings.xml')//series/season/driver[@id = $d/@id]
                return
                <statistics>
                        <season_points> {xs:string($driver/@points)} </season_points>
                        <wins> {xs:string($driver/@wins)} </wins>
                        <poles> {xs:string($driver/@poles)} </poles>
                        <races_not_finished> {xs:string($driver/@dnf)} </races_not_finished>
                        <laps_completed> {xs:string($driver/@laps_completed)} </laps_completed>
                    </statistics>
                )
                (: Caso contrario, seteamos en 0 a todos los subnodos:)
                else(
                    <statistics>
                        <season_points>0</season_points>
                        <wins>0</wins>
                        <poles>0</poles>
                        <races_not_finished>0</races_not_finished>
                        <laps_completed>0</laps_completed>
                    </statistics>
                )
            }
        </driver>
    }
    </drivers>
};

(: Retornamos la informacion pedida con la estructura del nascar_data.xsd :)
(: Si validan los parametros pasados por consola, procedemos a utilizar los documentos .xml generados :)
if(local:validateParameters())
    then(
        for $series in doc("drivers_standings.xml")//series
        return
        <nascar_data xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="nascar_data.xsd">
            <year> {xs:int($series/season/@year)} </year>
            <serie_type> {xs:string($series/@name)} </serie_type>
            {local:drivers()}
        </nascar_data>
    )
else(
    <nascar_data xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="nascar_data.xsd">
            
            {if(not(local:validateYear()))
            then(<error> {$InvalidYear} </error>)
            else()
            }
            {if(not(local:validateType()))
            then(<error> {$InvalidType} </error>)
            else()
            }
        </nascar_data>
)