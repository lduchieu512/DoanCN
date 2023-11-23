import React, { useState, useRef, useEffect } from "react";
import { Link } from "react-router-dom";
import "boxicons";
import { Collapse } from "react-bootstrap";

import sidebarJson from "../../assets/jsonData/sidebar.json";

const SidebarItem = (props) => {
  const active = props.active ? "active" : "";

  return (
    <div className="sidebar_item">
      <div className={`sidebar_item-inner ${active}`}>
        <i className={`bx bxs-${props.icon}`}></i>
        <span>{props.title}</span>
      </div>
    </div>
  );
};

const Sidebar = (props) => {
  const activeItem = sidebarJson.findIndex(
    (item) => item.route === props.location.pathname
  );
  const [isCollapse, setIsCollapse] = useState(false);
  let sidebarRef = useRef();

  const onToggleSidebar = () => {
    setIsCollapse(!isCollapse);
  };

  // useEffect(() => {
  //   isCollapse ? bsCollapse.show() : bsCollapse.hide();
  // }, [isCollapse]);

  return (
    <div className="sidebar">
      <div>
        <div className="sidebar_logo">
          <img src="" alt="Logo" />
        </div>
        {sidebarJson.map((item, index) => (
          <Link to={item.route} key={index}>
            <SidebarItem
              title={item.display_name}
              icon={item.icon}
              active={index === activeItem}
            />
          </Link>
        ))}
        <div className="sidebar_footer">
          <i className="bx bxs-chevrons-left" onClick={onToggleSidebar}></i>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
