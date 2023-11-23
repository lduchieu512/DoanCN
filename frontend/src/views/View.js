import React, { useContext, useEffect } from "react";
import { AuthContext } from "../contexts/AuthContext";
import { ViewContext } from "../contexts/ViewContent";
import { Spinner } from "react-bootstrap";
import { Bar } from "react-chartjs-2";
import InfoCol from "../components/layout/InfoCol";
import Money from "../assets/icon-moneybag.svg";
import Client from "../assets/icon-client.svg";
import Chart from "chart.js/auto";

const View = () => {
  const {
    authState: { user },
  } = useContext(AuthContext);
  const {
    viewState: { yearLoading, yearproduct, yearUsers },
    getBills,
  } = useContext(ViewContext);
  useEffect(() => {
    getBills();
  }, [user, yearLoading, getBills]);
  let body = null;
  let getDate = () => {
    if (yearLoading) {
      body = (
        <div className="spinner-container">
          <Spinner animation="border" variant="info" />
        </div>
      );
    } else {
      let labels = [];
      let monthOrders = [];
      let money = [];
      let Send = 0;
      yearproduct.map((Month) => {
        labels.push(Month[0]);
        monthOrders.push(Month[1].length);
        let hold = 0;
        Month[1].map((bill) => {
          hold += bill.total;
          Send += bill.total;
          return null;
        });
        money.push(hold);
        return null;
      });
      const data = {
        labels,
        datasets: [
          {
            label: "Orders",
            data: monthOrders,
            borderColor: "red",
            backgroundColor: "rgba(255, 99, 132, 0.5)",
          },
        ],
      };
      const dataMoney = {
        labels,
        datasets: [
          {
            label: "Money",
            data: money,
            borderColor: "red",
            backgroundColor: "rgba(53, 162, 235, 0.5)",
          },
        ],
      };

      body = (
        <>
          <div className="Container" style={{ marginLeft: "320px" }}>
            <div className="Chart-row">
              <div className="chart">
                <Bar data={data} />
              </div>
              <div className="chart">
                <Bar data={dataMoney} />
              </div>
            </div>
            <div className="Info-row">
              <InfoCol
                icon={Money}
                color="#EEEBFF"
                text={"$" + Send}
                description="Earned This Year"
              />
              <InfoCol
                icon={Client}
                color="#E5F9FE"
                text={yearUsers.length}
                description="Client"
              />
            </div>
          </div>
        </>
      );
    }
  };
  getDate();
  return <div>{body}</div>;
};

export default View;
