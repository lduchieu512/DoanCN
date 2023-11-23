import React from 'react'

const InfoCol = ({icon ,color, text, description}) => {
    console.log(text)
    return (
        <div className='Info-Col'>
            <div className="Info-icon" style={{background: color}}>
                <img style={{filter: "brightness(0) invert(1)"}} width={30} height={30} src={icon} alt="description" />
            </div>
            <div className="Info-text">
                <div className="upper">{text}</div>
                <div className="lower">{description}</div>
            </div>
        </div>
    )
}

export default InfoCol
